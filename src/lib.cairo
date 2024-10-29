use starknet::ContractAddress;
use starknet::storage::Vec;

#[starknet::interface]
trait FirstContract<TContractState> {
    fn vote(ref self: TContractState, vote: felt252);
    fn get_votes(self: @TContractState) -> (felt252, felt252);
}

#[starknet::contract]
mod MyFirstContract {
    use starknet::get_caller_address;
    use traits::Into;
    use super::{FirstContract, ContractAddress};
    use starknet::storage::{Map, Vec};

    #[storage]
    struct Storage {
        yes_votes: felt252,
        no_votes: felt252,
        voters: Map::<ContractAddress, bool>,
    }

    #[abi(embed_v0)]
    impl VotingContractImpl of FirstContract<ContractState> {
        fn vote(ref self: ContractState, vote: felt252) {
            assert((vote == 0) || (vote == 1), 'vote can only be 0/1');
            let caller = get_caller_address();

            assert(!self.voters.read(caller), 'you have already voted');

            if vote == 0 {
                self.no_votes.write(self.no_votes.read() + 1);
            } else if vote == 1 {
                self.yes_votes.write(self.yes_votes.read() + 1);
            }

            self.voters.write(caller, true);
        }

        fn get_votes(self: @ContractState) -> (felt252, felt252) {
            (self.no_votes.read(), self.yes_votes.read())
        }
    }
}
