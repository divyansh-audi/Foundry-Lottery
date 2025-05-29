//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "../../script/Interactions.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract InteractionTest is Test {
    Raffle raffle;
    HelperConfig helperConfig;

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.deployContract();
    }

    function testIfCreateSubscriptionCanInteract() public {
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        CreateSubscription cs = new CreateSubscription();
        cs.createSubscription(config.vrfCoordinator, config.account);
    }

    function testIfFundSubscriptionFailsWithoutCreatingASub() public {
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        FundSubscription fs = new FundSubscription();
        vm.expectRevert();
        fs.fundSubscription(
            config.vrfCoordinator,
            config.subscriptionId,
            config.link,
            config.account
        );
    }

    function testIfFundingIsDoneAfterCreatingSub() public {
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        CreateSubscription cs = new CreateSubscription();
        (uint256 subID, address vrfAdd) = cs.createSubscription(
            config.vrfCoordinator,
            config.account
        );
        FundSubscription fs = new FundSubscription();
        fs.fundSubscription(vrfAdd, subID, config.link, config.account);
    }

    function testIfAddConsumerFailsWithoutSub() public {
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        // CreateSubscription cs = new CreateSubscription();
        // (uint256 subID, address vrfAdd) = cs.createSubscription(
        //     config.vrfCoordinator,
        //     config.account
        // );
        AddConsumer ac = new AddConsumer();
        vm.expectRevert();
        ac.addConsumer(
            address(raffle),
            config.vrfCoordinator,
            config.subscriptionId,
            config.account
        );
    }

    function testIfAddConsumerWorksAfterAddingSub() public {
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        CreateSubscription cs = new CreateSubscription();
        (uint256 subID, address vrfAdd) = cs.createSubscription(
            config.vrfCoordinator,
            config.account
        );
        AddConsumer ac = new AddConsumer();
        // vm.expectRevert();
        ac.addConsumer(address(raffle), vrfAdd, subID, config.account);
    }
}
