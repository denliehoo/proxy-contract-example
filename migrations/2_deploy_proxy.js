const FunctionalDogs = artifacts.require("FunctionalDogs"); // Note: truffle looks for the contract name; not the file name
const Proxy = artifacts.require('Proxy');
const FunctionalDogsV2 = artifacts.require("FunctionalDogsV2")

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(FunctionalDogs);
    const functionalDogs = await FunctionalDogs.deployed();
    // deploys the Proxy contract and place the functional contract's address as a param
    await deployer.deploy(Proxy, functionalDogs.address);
    const proxy = await Proxy.deployed()

    /* We are unable to do e.g. await proxy.setNumberOfDogs(10) because that function
    doesn't actually exist in the proxy contract. Instead we must do 
    cosnt proxyFunctional = await FunctionalContract.at(proxy.address); and we will be
    able to interact from there. 
    this takes the source code of the functional contract
    and .at tells truffle to create an instance of the functional contract,
    but do that from an existing deployed contract.
    Hence, by doing this, we are able to "fool" truffle. Note this is only for when 
    we want to interact with truffle.*/
    let proxyFunctional = await FunctionalDogs.at(proxy.address);
    await proxyFunctional.setNumberOfDogs(10);

    let numOfDogs = await proxyFunctional.getNumberOfDogs();
    console.log("number of dogs: ", numOfDogs.toString()); // should be 10
    // remember: storage is done in the proxy contract and not the functional contract
    // hence if we do functionaldogs.getNumberOfDogs() it would still be 0 

    // =========== upgrading the Functional Contract ================
    await deployer.deploy(FunctionalDogsV2);
    const functionalDogsV2 = await FunctionalDogsV2.deployed();

    // upgrade the contract
    await proxy.upgrade(functionalDogsV2.address);
    // we have to fool truffle again since the address changed
    proxyFunctional = await FunctionalDogsV2.at(proxy.address);
    // initialize the proxy state
    proxyFunctional.initialize(accounts[0]) // since accounts[0] is the msg.sender for functional contract

    // checks that storage is done properly; numberOfDogs should still be 10
    numOfDogs = await proxyFunctional.getNumberOfDogs();
    console.log("number of dogs is still: ", numOfDogs.toString()); // should be 10

    // set number of dogs
    await proxyFunctional.setNumberOfDogs(30);
    numOfDogs = await proxyFunctional.getNumberOfDogs();
    console.log("after change: ", numOfDogs.toString()); // should be 30

    // this should fail
    await proxyFunctional.setNumberOfDogs(30, { from: accounts[1] });
};
