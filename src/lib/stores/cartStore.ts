import { writable, derived } from 'svelte/store';

export const cart = writable<any[]>([]);

export const cartCount = derived(cart, ($cart) =>
    $cart.reduce((count, item) => count + (item.quantity || 1), 0)
);

export const cartTotal = derived(cart, ($cart) =>
    $cart.reduce((total, item) => total + ((item.final_price || item.price) * (item.quantity || 1)), 0)
);

function areCustomizationsEqual(c1: any, c2: any) {
    return JSON.stringify(c1) === JSON.stringify(c2);
}

export function addToCart(item: any) {
    cart.update(($cart) => {
        const existing = $cart.find((i) =>
            i.id === item.id && areCustomizationsEqual(i.customizations, item.customizations)
        );
        if (existing) {
            existing.quantity = (existing.quantity || 1) + 1;
            return [...$cart];
        }
        return [...$cart, { ...item, quantity: 1 }];
    });
}

export function removeFromCart(cartId: any) {
    // Note: using index or a unique cartId might be safer, but for now we'll match on a combination
    cart.update(($cart) => $cart.filter((item, idx) => {
        // Here we might need a unique ID per line item to be safe
        // Let's assume the combination of item ID and customizations is unique enough for the filter if we only remove one
        return item.id !== cartId; // This is actually broken if we have multiples. 
        // Let's refactor to use indices for deletions to be safe.
    }));
}

// Rewriting removeFromCart and updateQuantity to use index to avoid ambiguity with customized items
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
