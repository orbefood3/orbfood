import { writable, derived } from 'svelte/store';

export const cart = writable<any[]>([]);

export const cartCount = derived(cart, ($cart) =>
    $cart.reduce((count, item) => count + (item.quantity || 1), 0)
);

export const cartTotal = derived(cart, ($cart) =>
    $cart.reduce((total, item) => total + ((item.final_price || item.price) * (item.quantity || 1)), 0)
);

/**
 * Deep equality check for customizations to distinguish between variations of same item.
 * Customizations format: Array<{ group_id, group_name, selected_items: Array<{ id, name, price, qty }> }>
 */
function areCustomizationsEqual(c1: any, c2: any) {
    if (!c1 && !c2) return true;
    if (!c1 || !c2) return false;
    return JSON.stringify(c1) === JSON.stringify(c2);
}

export function addToCart(item: any) {
    cart.update(($cart) => {
        // Find existing match with EXACT same customizations
        const existingIndex = $cart.findIndex((i) =>
            i.id === item.id && areCustomizationsEqual(i.customizations, item.customizations)
        );

        if (existingIndex !== -1) {
            const updated = [...$cart];
            updated[existingIndex] = {
                ...updated[existingIndex],
                quantity: (updated[existingIndex].quantity || 1) + (item.quantity || 1)
            };
            return updated;
        }

        return [...$cart, { ...item, quantity: item.quantity || 1 }];
    });
}

export function updateItemByIndex(index: number, updatedItem: any) {
    cart.update(($cart) => {
        const newCart = [...$cart];
        if (index >= 0 && index < newCart.length) {
            newCart[index] = { ...newCart[index], ...updatedItem };
        }
        return newCart;
    });
}

export function removeItemByIndex(index: number) {
    cart.update(($cart) => {
        return $cart.filter((_, i) => i !== index);
    });
}

export function updateQuantityByIndex(index: number, delta: number) {
    cart.update(($cart) => {
        return $cart.map((item, i) => {
            if (i === index) {
                const newQty = (item.quantity || 1) + delta;
                return { ...item, quantity: Math.max(1, newQty) };
            }
            return item;
        });
    });
}

export function clearCart() {
    cart.set([]);
}
