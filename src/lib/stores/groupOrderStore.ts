import { writable } from 'svelte/store';
import type { OrderRoom } from '../types/groupOrder';

function createGroupOrderStore() {
    const { subscribe, set, update } = writable<OrderRoom | null>(null);

    return {
        subscribe,
        setRoom: (room: OrderRoom) => {
            // Persist to sessionStorage to survive refreshes
            sessionStorage.setItem('activeGroupOrder', JSON.stringify(room));
            set(room);
        },
        clearRoom: () => {
            sessionStorage.removeItem('activeGroupOrder');
            set(null);
        },
        loadFromStorage: () => {
            const stored = sessionStorage.getItem('activeGroupOrder');
            if (stored) {
                try {
                    set(JSON.parse(stored));
                } catch (e) {
                    console.error("Failed to parse stored group order", e);
                    sessionStorage.removeItem('activeGroupOrder');
                }
            }
        }
    };
}

export const groupOrderStore = createGroupOrderStore();
