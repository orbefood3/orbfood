export interface OrderRoom {
    id: string;
    store_id: string;
    creator_id: string | null;
    name: string;
    short_code: string;
    closing_time: string; // ISO string
    status: 'open' | 'closed' | 'sent';
    is_shop_managed?: boolean | null;
    created_at: string;
    participant_count?: number; // Virtual field for UI
}

export interface GroupOrderParticipant {
    id: string; // Order History ID
    user_id: string | null;
    participant_name: string;
    total_price: number;
    items: any[]; // JSONB content
    status: string;
    transfer_proof_url?: string;
    payment_status: 'none' | 'pending' | 'verified';
}
