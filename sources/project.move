module StakingPlatform::StakingPlatform {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    const EPOOL_ALREADY_EXISTS: u64 = 1;
    const ENO_POOL: u64 = 2;
    const EINVALID_AMOUNT: u64 = 3;

    struct StakingPool has store, key {
        total_staked: u64,
    }

    public fun create_pool(owner: &signer) {
        let owner_addr = signer::address_of(owner);
        if (exists<StakingPool>(owner_addr)) {
            abort EPOOL_ALREADY_EXISTS;
        };
        let pool = StakingPool { total_staked: 0 };
        move_to(owner, pool);
    }

    public fun stake_tokens(staker: &signer, pool_owner: address, amount: u64) acquires StakingPool {
        if (!exists<StakingPool>(pool_owner)) {
            abort ENO_POOL;
        };
        assert!(amount > 0, EINVALID_AMOUNT);

        let pool = borrow_global_mut<StakingPool>(pool_owner);

        let stake = coin::withdraw<AptosCoin>(staker, amount);
        coin::deposit<AptosCoin>(pool_owner, stake);

        pool.total_staked = pool.total_staked + amount;
    }

    public fun get_total_staked(pool_owner: address): u64 acquires StakingPool {
        if (!exists<StakingPool>(pool_owner)) {
            abort ENO_POOL;
        };
        let pool = borrow_global<StakingPool>(pool_owner);
        pool.total_staked
    }
}
