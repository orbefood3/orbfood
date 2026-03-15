import { writable } from 'svelte/store';
import type { OrderRoom } from '../types/groupOrder';

function createGroupOrderStore() {
    const { subscribe, set, update } = writable<OrderRoom | null>(null);

    return {
        subscribe,
        setGroup: (room: OrderRoom) => {
            // Persist to localStorage to survive refreshes
            localStorage.setItem('activeGroupOrder', JSON.stringify(room));
            set(room);
        },
        clearGroup: () => {
            localStorage.removeItem('activeGroupOrder');
            set(null);
        },
        loadFromStorage: () => {
            const stored = localStorage.getItem('activeGroupOrder');
            if (stored) {
                try {
                    const room = JSON.parse(stored) as OrderRoom;
                    // Auto-clear if already past closing time (expired)
                    const isExpired = room.closing_time && new Date(room.closing_time) < new Date();
                    const isInvalid = room.status && room.status !== 'open';

                    if (isExpired || isInvalid) {
                        localStorage.removeItem('activeGroupOrder');
                        set(null);
                    } else {
                        set(room);
                    }
                } catch (e) {
                    console.error("Failed to parse stored group order", e);
                    localStorage.removeItem('activeGroupOrder');
                }
            }
        }
    };
}

export const groupOrderStore = createGroupOrderStore();
