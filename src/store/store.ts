/* === IMPORTS ============================ */
import { writable, type Writable } from 'svelte/store';
import type { GlobeInstance } from 'globe.gl';

/* === TYPES ============================== */
export type Country = {
    id: string,
    totalPopulation: number
};

/* === STORES ============================= */
export const UGNglobe: Writable<GlobeInstance | null> = writable(null);
export const UGNcountryInfo: Writable<{ [key: string]: {name: string, altName?: string, flag: string, lat: number, lng: number} }> = writable({});
export const UGNpopulationData: Writable<{ time: string, countries: { id: string, population: number[][] }[] }[]> = writable([]);
export const UGNcurTimeIndex = writable(0);
export const UGNcurCountries: Writable<Country[]> = writable([]);
export const UGNglobeHoverCountry: Writable<Country | null> = writable(null);
export const UGNlistHoverCountry: Writable<Country | null> = writable(null);
export const UGNsexSelection = writable([0]);
export const UGNageSelection = writable([0, 1, 2]);
export const UGNverticalLayout = writable(false);
export const UGNaltOffset = writable(0);