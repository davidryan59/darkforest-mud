// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { Errors } from "../interfaces/errors.sol";
import { UniverseConfig, Ticker, MoveData } from "../codegen/index.sol";
import { Planet } from "../lib/Planet.sol";
import { MoveLib } from "../lib/Move.sol";

contract PlanetSystem is System, Errors {
  using MoveLib for MoveData;

  function readPlanet(uint256 planetHash, uint256 perlin, uint256 distanceSquare)
    public
    view
    returns (Planet memory planet)
  {
    planet.planetHash = planetHash;
    planet.perlin = perlin;
    planet.distSquare = distanceSquare;
    planet.readFromStore();
    _sync(planet);
  }

  function readPlanet(uint256 planetHash) public view returns (Planet memory planet) {
    planet.planetHash = planetHash;
    planet.readFromStore();
    _sync(planet);
  }

  function upgradePlanet(uint256 planetHash, uint256 rangeUpgrades, uint256 speedUpgrades, uint256 defenseUpgrades) public {
    Planet memory planet = readPlanet(planetHash);
    address executor = _msgSender();
    planet.upgrade(executor, rangeUpgrades, speedUpgrades, defenseUpgrades);
    planet.writeToStore();
  }

  function _sync(Planet memory planet) internal view {
    uint256 untilTick = Ticker.getTickNumber();
    MoveData memory move = planet.popArrivedMove(untilTick);
    while (uint256(move.from) != 0) {
      planet.naturalGrowth(move.arrivalTime);
      move.arrivedAt(planet);
      move = planet.popArrivedMove(untilTick);
    }
    planet.naturalGrowth(untilTick);
  }
}
