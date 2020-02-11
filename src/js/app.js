App = {
  web3Provider: null,
  contracts: {},

  init: async function () {

    await App.initWeb3();

    await App.initContract();

    await App.render();

    App.bindEvents();
  },

  initWeb3: async function () {
    // Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable();
        console.log("Using modern dapp browser (metamask) as web3 provider");
      } catch (error) {
        // User denied account access...
        console.error("User denied account access")
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      console.log("Using legacy dapp browser as web3 provider");
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      console.log("Using localhost as web3 provider");
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);
  },

  initContract: async function () {
    let data = await $.getJSON('Cryptomon.json');

    // Get the necessary contract artifact file and instantiate it with truffle-contract
    var CryptomonArtifact = data;
    App.contracts.Cryptomon = TruffleContract(CryptomonArtifact);

    // Set the provider for our contract
    App.contracts.Cryptomon.setProvider(App.web3Provider);
  },

  bindEvents: function () {
    $(document).on('click', '.btn-fight', App.handleFight);
    $(document).on('click', '.btn-evolve', App.handleEvolve);
    $(document).on('click', '.btn-revive', App.handleRevive);
    $(document).on('click', '.btn-breed', App.handleBreed);
    $(document).on('click', '.btn-buy', App.handleBuy);
    $(document).on('click', '.btn-sell', App.handleSell);
    $(document).on('click', '.btn-withdraw', App.handleWithdraw);
  },

  handleFight: async function (event) {
    event.preventDefault();
    let id = parseInt($(event.target).data('id'));
    let crt = await App.contracts.Cryptomon.deployed();
    let opponent = $(event.target).closest('.span-fight').find('#select-id').val();
    console.log(opponent);
    await crt.fight(id, opponent);
    await App.render();
  },

  handleEvolve: async function (event) {
    event.preventDefault();
    let id = parseInt($(event.target).data('id'));
    let crt = await App.contracts.Cryptomon.deployed();
    await crt.evolve(id);
    await App.render();
  },

  handleRevive: async function (event) {
    event.preventDefault();
    let id = parseInt($(event.target).data('id'));
    let crt = await App.contracts.Cryptomon.deployed();
    let price = await crt._revivePrice.call();
    await crt.revive(id, { value: price });
    await App.render();
  },

  handleBreed: async function (event) {
    event.preventDefault();
    let id = parseInt($(event.target).data('id'));
    let crt = await App.contracts.Cryptomon.deployed();
    await crt.breed(id);
    await App.render();
  },

  handleBuy: async function (event) {
    event.preventDefault();
    let id = parseInt($(event.target).data('id'));
    let crt = await App.contracts.Cryptomon.deployed();
    let price = await crt._pokPrice.call(id);
    await crt.buyPokemon(id, { value: price });
    await App.render();
  },

  handleSell: async function (event) {
    event.preventDefault();
    let id = parseInt($(event.target).data('id'));
    let crt = await App.contracts.Cryptomon.deployed();
    let userPrice = $(event.target).closest('.span-sell').find('.pok-sell-price').val();
    let price = web3.toWei(userPrice);
    await crt.sellPokemon(id, price);
    await App.render();
  },

  handleWithdraw: async function (event) {
    event.preventDefault();
    let crt = await App.contracts.Cryptomon.deployed();
    await crt.withdrawFunds.sendTransaction();
    await App.render();
  },

  render: async function (buyers, account) {

    var account;

    let crt = await App.contracts.Cryptomon.deployed();

    // Display account number
    web3.eth.getAccounts((error, accounts) => {
      account = accounts[0];
      if (error) {
        console.error(error);
      }
      document.getElementById("account-num").textContent = account;
    })

    // Display balance owed by contract
    let balanceOwed = web3.fromWei(await crt.checkBalance.call());
    document.getElementById("balance").textContent = balanceOwed;

    // Get species index to text conversions
    let data = await $.getJSON('../pokemon.json');

    // Render cards
    var pokRow = $('#pokRow').empty();
    var pokTemplate = $('#pokTemplate');
    let numPok = await crt._totalNumPokemon.call();
    for (let id = 0; id < numPok; id++) {
      let card = pokTemplate.clone();

      // id
      card.find('.pok-id').text(id);

      let speciesId = parseInt(await crt._pokSpeciesId.call(id));
      card.find('.panel-title').text(data[speciesId].name);
      card.find('.pok-type').text(data[speciesId].type);
      card.find('.pok-evolves-to').text(data[speciesId].evolvesTo);
      card.find('.pok-breeds-to').text(data[speciesId].breedsTo);
      card.find('img').attr('src', data[speciesId].picture);

      let owner = await crt._pokOwner.call(id);
      let userOwnsThis = owner == account;

      let gen = parseInt(await crt._pokGeneration.call(id));
      card.find('.pok-generation').text(gen);

      let level = parseInt(await crt._pokLevel.call(id));
      card.find('.pok-level').text(level);

      let price = web3.fromWei(await crt._pokPrice.call(id));
      card.find('.pok-buy-price').text(price);

      // Link each button up with its id
      card.find('.btn').attr('data-id', id);

      // Fight
      let stunned = await crt._pokStunned.call(id);
      if (stunned || !userOwnsThis) {
        card.find('.span-fight').empty();
      } else {
        let dropdown = card.find('#select-id');
        for (let otherId = 0; otherId < numPok; otherId++) {
          if (otherId == id) { continue };
          if (await crt._pokStunned.call(otherId)) { continue };
          dropdown.append($("<option>", { value: otherId, text: otherId }));
        }
      }

      // Evolve
      let canEvolve = await crt._pokCanEvolve.call(id);
      if (!canEvolve || !userOwnsThis) {
        card.find('.span-evolve').empty();
      }

      // Revive
      if (!stunned || !userOwnsThis) {
        card.find('.span-revive').empty();
      } 

      // Breed
      let timesCanBreed = parseInt(await crt._pokTimesCanBreed.call(id));
      card.find('.pok-times-can-breed').text(timesCanBreed);
      if (timesCanBreed < 1 || !userOwnsThis) {
        card.find('.span-breed').empty();
      }

      // Buy
      let forSale = await crt._pokForSale.call(id);
      if (!forSale) {
        card.find('.span-buy').empty();
      }
      if (userOwnsThis) {
        card.find('.btn-buy').attr('disabled', true);
      }

      // Sell
      if (!userOwnsThis) {
        card.find('.span-sell').empty();
      }

      pokRow.append(card.html());
    }

  }

};

$(function () {
  $(window).load(function () {
    App.init();
  });
});
