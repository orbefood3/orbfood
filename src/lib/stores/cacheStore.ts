import { writable, get } from 'svelte/store';

interface CacheEntry<T> {
    data: T;
    timestamp: number;
}

// Cache TTL: 5 minutes for data that rarely changes
const CACHE_TTL = 5 * 60 * 1000;

const STORAGE_KEY_VILLAGES = 'orb_cache_villages';
const STORAGE_KEY_SHOPS = 'orb_cache_shops';

function createCacheStore<T>(storageKey: string) {
    // Try to load from sessionStorage on init
    let initial: CacheEntry<T> | null = null;

    if (typeof sessionStorage !== 'undefined') {
        try {
            const stored = sessionStorage.getItem(storageKey);
            if (stored) {
                initial = JSON.parse(stored);
            }
        } catch (e) {
            console.warn('Failed to parse cache:', e);
        }
    }

    const store = writable<CacheEntry<T> | null>(initial);

    return {
        subscribe: store.subscribe,

        set(data: T) {
            const entry: CacheEntry<T> = {
                data,
                timestamp: Date.now()
            };
            store.set(entry);

            // Persist to sessionStorage
            if (typeof sessionStorage !== 'undefined') {
                try {
                    sessionStorage.setItem(storageKey, JSON.stringify(entry));
                } catch (e) {
                    console.warn('Failed to save cache:', e);
                }
            }
        },

        get(): T | null {
            const entry = get(store);
            if (!entry) return null;

            // Check if cache is still valid
            if (Date.now() - entry.timestamp > CACHE_TTL) {
                // Cache expired
                store.set(null);
                if (typeof sessionStorage !== 'undefined') {
                    sessionStorage.removeItem(storageKey);
                }
                return null;
            }

            return entry.data;
        },

        isValid(): boolean {
            const entry = get(store);
            if (!entry) return false;
            return Date.now() - entry.timestamp <= CACHE_TTL;
        },

        clear() {
            store.set(null);
            if (typeof sessionStorage !== 'undefined') {
                sessionStorage.removeItem(storageKey);
            }
        }
    };
}

export const villagesCache = createCacheStore<any[]>(STORAGE_KEY_VILLAGES);
export const shopsCache = createCacheStore<any[]>(STORAGE_KEY_SHOPS);
