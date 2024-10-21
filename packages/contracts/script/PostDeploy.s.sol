// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { stdToml } from "forge-std/StdToml.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { SpaceType, PlanetType, ArtifactRarity } from "../src/codegen/common.sol";
import { PlanetMetadata, PlanetMetadataData, Planet, PlanetData, PlanetOwner, PlanetConstants } from "../src/codegen/index.sol";
import { PlanetInitialResource, PlanetInitialResourceData } from "../src/codegen/index.sol";
import { UniverseConfig, UniverseConfigData, TempConfigSet, TempConfigSetData } from "../src/codegen/index.sol";
import { SpaceTypeConfig, SpaceTypeConfigData } from "../src/codegen/index.sol";
import { UniverseZoneConfig, UniverseZoneConfigData } from "../src/codegen/index.sol";
import { PlanetLevelConfig, PlanetTypeConfig } from "../src/codegen/index.sol";
import { SnarkConfig, SnarkConfigData, Ticker } from "../src/codegen/index.sol";
import { InnerCircle, InnerCircleData } from "../src/codegen/index.sol";
import { UpgradeConfig, UpgradeConfigData } from "../src/codegen/index.sol";
import { RevealedPlanet, PlanetBiomeConfig, PlanetBiomeConfigData, ArtifactConfig } from "../src/codegen/index.sol";

contract PostDeploy is Script {
  using stdToml for string;
  using Strings for uint256;

  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // Set planet metadata
    _setPlanetMetadata(worldAddress);

    // configure the universe
    string memory tomlPath = "df.config.toml";
    string memory toml = vm.readFile(tomlPath);
    UniverseConfig.set(abi.decode(toml.parseRaw(".universe"), (UniverseConfigData)));
    TempConfigSet.set(abi.decode(toml.parseRaw(".temp"), (TempConfigSetData)));
    SpaceTypeConfig.set(abi.decode(toml.parseRaw(".space_type"), (SpaceTypeConfigData)));
    UniverseZoneConfig.set(abi.decode(toml.parseRaw(".universe_zone"), (UniverseZoneConfigData)));
    PlanetLevelConfig.set(abi.decode(toml.parseRaw(".planet_level.thresholds"), (uint32[])));
    PlanetBiomeConfig.set(abi.decode(toml.parseRaw(".planet_biome"), (PlanetBiomeConfigData)));
    for (uint256 i = 1; i <= uint8(type(SpaceType).max); i++) {
      for (uint256 j; j <= PlanetLevelConfig.length(); j++) {
        string memory key = string.concat(".planet_type.thresholds.", i.toString(), ".", j.toString());
        PlanetTypeConfig.set(SpaceType(uint8(i)), uint8(j), abi.decode(toml.parseRaw(key), (uint16[])));
      }
    }
    SnarkConfig.set(abi.decode(toml.parseRaw(".snark"), (SnarkConfigData)));
    Ticker.set(0, uint64(toml.readUint(".ticker.rate")), 0, true);
    InnerCircle.set(abi.decode(toml.parseRaw(".inner_circle"), (InnerCircleData)));
    UpgradeConfig.set(abi.decode(toml.parseRaw(".upgrade_config"), (UpgradeConfigData)));
    for (uint256 i = 1; i <= uint8(type(ArtifactRarity).max); i++) {
      string memory key = string.concat(".artifact.", i.toString());
      ArtifactConfig.set(ArtifactRarity(i), abi.decode(toml.parseRaw(key), (uint16[])));
    }

    // set test planets
    if (toml.readBool(".temp.b_skip_proof_check")) {
      _setTestPlanets(abi.decode(toml.parseRaw(".test_planets_fake"), (TestPlanet[])));
    } else {
      // PUNK
      // _setTestPlanets(abi.decode(toml.parseRaw(".test_planets"), (TestPlanet[])));
    }

    // register fallback delegation of df namespace
    IWorld(worldAddress).registerNamespaceDelegation(
      WorldResourceIdLib.encodeNamespace("df"),
      WorldResourceIdLib.encode("sy", "df", "DfDelegationCtrl"),
      new bytes(0)
    );

    vm.stopBroadcast();
  }

  function _setPlanetMetadata(address worldAddress) internal {
    console.log("Setting planet metadata");
    IWorld(worldAddress).df__setPlanetMetadata(
      0,
      PlanetMetadataData(99, 160, 400, 100000, 417, 0, 0), // range, speed, defense, populationCap, populationGrowth, silverCap, silverGrowth
      0 // initialPopulationPercentage
    );

    IWorld(worldAddress).df__setPlanetMetadata(1, PlanetMetadataData(177, 160, 400, 400000, 833, 100000, 56), 1);
    IWorld(worldAddress).df__setPlanetMetadata(2, PlanetMetadataData(315, 160, 300, 1600000, 1250, 500000, 167), 2);
    IWorld(worldAddress).df__setPlanetMetadata(3, PlanetMetadataData(591, 160, 300, 6000000, 1667, 2500000, 417), 3);
    IWorld(worldAddress).df__setPlanetMetadata(4, PlanetMetadataData(1025, 160, 300, 25000000, 2083, 12000000, 833), 4);
    IWorld(worldAddress).df__setPlanetMetadata(
      5,
      PlanetMetadataData(1734, 160, 200, 100000000, 2500, 50000000, 1667),
      5
    );
    IWorld(worldAddress).df__setPlanetMetadata(
      6,
      PlanetMetadataData(2838, 160, 200, 300000000, 2917, 100000000, 2778),
      7
    );
    IWorld(worldAddress).df__setPlanetMetadata(
      7,
      PlanetMetadataData(4414, 160, 200, 500000000, 3333, 200000000, 2778),
      10
    );
    IWorld(worldAddress).df__setPlanetMetadata(
      8,
      PlanetMetadataData(6306, 160, 200, 700000000, 3750, 300000000, 2778),
      20
    );
    IWorld(worldAddress).df__setPlanetMetadata(
      9,
      PlanetMetadataData(8829, 160, 200, 800000000, 4167, 400000000, 2778),
      25
    );
  }

  struct TestPlanet {
    int32 x;
    int32 y;
    bytes32 planetHash;
    address owner;
    uint64 lastUpdateTick;
    uint8 perlin;
    uint8 level;
    PlanetType planetType;
    SpaceType spaceType;
    uint64 population;
    uint64 silver;
    uint24 upgrades;
  }

  function _setTestPlanets(TestPlanet[] memory planets) internal {
    console.log("Dropping test planets");
    for (uint256 i; i < planets.length; i++) {
      PlanetConstants.set(
        planets[i].planetHash,
        planets[i].perlin,
        planets[i].level,
        planets[i].planetType,
        planets[i].spaceType
      );
      Planet.set(
        planets[i].planetHash,
        planets[i].lastUpdateTick,
        planets[i].population,
        planets[i].silver,
        planets[i].upgrades,
        false
      );
      PlanetOwner.set(planets[i].planetHash, planets[i].owner);
      RevealedPlanet.set(planets[i].planetHash, planets[i].x, planets[i].y, planets[i].owner);
    }
  }
}
