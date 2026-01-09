import { writable, derived } from 'svelte/store';

export const cart = writable<any[]>([]);

export const cartCount = derived(cart, ($cart) =>
    $cart.reduce((count, item) => count + (item.quantity || 1), 0)
);

export const cartTotal = derived(cart, ($cart) =>
    $cart.reduce((total, item) => total + (item.price * (item.quantity || 1)), 0)
);

export function addToCart(item: any) {
    cart.update(($cart) => {
        const existing = $cart.find((i) => i.id === item.id);
        if (existing) {
            existing.quantity = (existing.quantity || 1) + 1;
            return [...$cart];
        }
        return [...$cart, { ...item, quantity: 1 }];
    });
}

export function removeFromCart(id: any) {
    cart.update(($cart) => $cart.filter((item) => item.id !== id));
}

export function updateQuantity(id: any, delta: number) {
    cart.update(($cart) => {
        return $cart.map((item) => {
            if (item.id === id) {
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
