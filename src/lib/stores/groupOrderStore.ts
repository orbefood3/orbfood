import { writable } from 'svelte/store';
import type { OrderRoom } from '../types/groupOrder';

function createGroupOrderStore() {
    const { subscribe, set, update } = writable<OrderRoom | null>(null);

    return {
        subscribe,
        setRoom: (room: OrderRoom) => {
            // Persist to localStorage to survive refreshes
            localStorage.setItem('activeGroupOrder', JSON.stringify(room));
            set(room);
        },
        clearRoom: () => {
            localStorage.removeItem('activeGroupOrder');
            set(null);
        },
        loadFromStorage: () => {
            const stored = localStorage.getItem('activeGroupOrder');
            if (stored) {
                try {
                    set(JSON.parse(stored));
                } catch (e) {
                    console.error("Failed to parse stored group order", e);
                    localStorage.removeItem('activeGroupOrder');
                }
            }
        }
    };
}

export const groupOrderStore = createGroupOrderStore();
