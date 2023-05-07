import { get as getStore, writable } from 'svelte/store';

import { openModal } from './components/Modal.svelte';
import { clone, equals } from './utils';

export type Setting = {
    type: string;
    name: string;

    value: any;
    values: any;
    negativeEqualsNotSet: boolean | undefined;
    stringType: string | undefined;
    settings: Setting[] | undefined;
    defaultValues: any;
};

export type Group = {
    id: number;
    name: string;

    configuration: boolean;
    platform: boolean;

    settings: Setting[];
};

export type Schema = {
    id: string;

    configurations: string[];
    configuration: string;

    platforms: string[];
    platform: string;

    groups: Group[];
};

class SettingValues {
    private values = {};
    private newValues = {};

    public load(o: any) {
        this.values = {};
        this.newValues = {};

        o.groups.forEach(group => {
            for (const setting in group.settings) {
                this.values[group.id + ";" + setting] = group.settings[setting];
            }
        });

        this.changed();
    }

    private changed() {
        settingValues.set(getStore(settingValues));
    }

    public isChanged(group: Group, setting: Setting): boolean {
        return this.newValues[group.id + ";" + setting.name] != undefined;
    }

    public changedCount(): number {
        return Object.keys(this.newValues).length;
    }

    public hasChanged(): boolean {
        return this.changedCount() > 0;
    }

    private getGroup(groups: any[], groupIndex: number): any {
        const schemaGroup = this.getSchemaGroupFromIndex(groupIndex);
        if(schemaGroup == null) {
            return; //This may error, but it is unlikely
        }

        for (let i = 0; i < groups.length; i++) {
            const group = groups[i];
            if (group.id === schemaGroup.id) return group;
        }

        const group = {
            id: schemaGroup.id,
            settings: {}
        };

        groups.push(group);
        return group;
    }

    private getSchemaGroupFromIndex(groupIndex : number) : any {
        var toReturn : Group | null = null;
        getStore(schema).groups.forEach(element => {
            if(element.id == groupIndex) {
                toReturn = element;
            }
        });
        return toReturn;
    }

    public apply() {
        let groups = [];

        for (const key in this.newValues) {
            
            const split = key.split(";");
            const group = this.getGroup(groups, parseInt(split[0]));
            group.settings[ 
                (split.length > 2) ? //This does potentially break if we ever create 3 split settings. 
                    split[1] + ';' + split[2] : 
                    split[1]
            ] = this.newValues[key];
        }

        const s = getStore(schema);
        vscode.postMessage({
            type: "set-values",
            id: s.id,
            configuration: s.configuration,
            platform: s.platform,
            groups: groups
        });

        loadValues();
        this.changed();
    }

    public reset() {
        this.newValues = {};
        this.changed();
    }

    // Get

    private get(group: Group, setting: Setting): any {
        const name = group.id + ";" + setting.name;

        const value = this.newValues[name];
        return value != undefined ? value : this.values[name];
    }

    getBool(group: Group, setting: Setting): boolean {
        const value = this.get(group, setting);
        return value != undefined ? value : false;
    }

    getString(group: Group, setting: Setting): string {
        const value = this.get(group, setting);
        return value != undefined ? value : "";
    }

    getInt(group: Group, setting: Setting): number {
        const value = this.get(group, setting);
        return value != undefined ? value : 0;
    }

    getList(group: Group, setting: Setting): any[] {
        const value = this.get(group, setting);
        if (value === undefined) return [];

        return clone(value);
    }

    getObject(group: Group, setting: Setting): any {
        const value = this.get(group, setting);
        if (value === undefined) return {};

        return clone(value);
    }

    // Set

    public set(group: Group, setting: Setting, value: any) {
        if (value == undefined || value == null) return;

        const name = group.id + ";" + setting.name;

        if (equals(this.values[name], value)) delete this.newValues[name];
        else this.newValues[name] = value;

        this.changed();
    }
}

export const schema = writable<Schema>({ id: "", configurations: [], configuration: "", platforms: [], platform: "", groups: [] });
export const currentGroup = writable<Group>();

export const settingValues = writable<SettingValues>(new SettingValues());

let vscode;

export function initSettings() {
    vscode = window["acquireVsCodeApi"]();

    addEventListener("message", event => {
        if (event.data.message === "schema") {
            const s = event.data.schema as Schema;

            schema.set(s);
            currentGroup.set(s.groups[0]);

            loadValues();
        }
        else if (event.data.message === "values") {
            getStore(settingValues).load(event.data.values);
        }
    });
}

export function setConfiguration(configuration: string) {
    const action = () => {
        getStore(schema).configuration = configuration;
        loadValues();
    };

    if (getStore(settingValues).hasChanged()) {
        showModal(action);
        return;
    }

    action();
}

export function setPlatform(platform: string) {
    const action = () => {
        getStore(schema).platform = platform;
        loadValues();
    };

    if (getStore(settingValues).hasChanged()) {
        showModal(action);
        return;
    }

    action();
}

function showModal(callback: { (): void }) {
    const count = getStore(settingValues).changedCount();

    openModal(
        `You have ${count} modified ${count > 1 ? "settings" : "setting"}. What do you want to do?`,
        [ "Apply", "Reset", "Go Back" ],
        value => {
            if (value === 0) {
                getStore(settingValues).apply();
                callback();
            }
            else if (value === 1) {
                getStore(settingValues).reset();
                callback();
            }
            else {
                schema.set(getStore(schema)); // Since the schema didn't change but the dropdown is already changed cause a redraw to reset it
            }
        }
    );
}

function loadValues() {
    const s = getStore(schema);

    vscode.postMessage({
        type: "values",
        id: s.id,
        configuration: s.configuration,
        platform: s.platform
    });
}