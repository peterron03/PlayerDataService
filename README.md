# PlayerDataService
A relatively simple wrapper over ProfileStore, with additions from DataStoreService.

## What exactly is PlayerDataService?
Essentially, PlayerDataService simplifies the simultaneous use of ProfileStore and DataStoreService. ProfileStore is obviously intended for *player* data, more specifically when the player is still in the game (with the exception of messages). PlayerDataService incorporates this, but adds in the things it doesn't allow for, such as OrderedDataStores and overall non-player data. Yes, I understand using a service named **Player**DataService for data that isn't specific to the player is a bit contradictory, but I couldn't think of a better name.

## Dependencies (IMPORTANT)
PlayerDataService currently has 2 dependencies - [ProfileStore](https://github.com/peterron03/PlayerDataService/blob/main/src/Packages/ProfileStore.luau) and [Signal](https://github.com/peterron03/PlayerDataService/blob/main/src/Packages/Signal.luau). Both of these dependencies are found within `src` under the `Packages` folder. Unless you edit the source code yourself to work differently, PlayerDataService will NOT work without it's dependencies. Please make sure you're using them.

## Examples
soon

## Documentation
soon
