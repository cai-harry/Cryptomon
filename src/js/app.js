App = {
  web3Provider: null,
  contracts: {},

  init: async function () {
    // let data = await $.getJSON('../pokemon.json');

    // var pokRow = $('#pokRow');
    // var pokTemplate = $('#pokTemplate');

    // for (i = 0; i < data.length; i++) {
    //   pokTemplate.find('.panel-title').text(data[i].name);
    //   pokTemplate.find('img').attr('src', data[i].picture);
    //   pokTemplate.find('.pok-type').text(data[i].type);
    //   pokTemplate.find('.pok-level').text(data[i].age);
    //   pokTemplate.find('.pok-evolves-to').text(data[i].evolvesTo);
    //   pokTemplate.find('.btn-buy').attr('data-id', data[i].id);

    //   pokRow.append(pokTemplate.html());
    // };

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
    $(document).on('click', '.btn-buy', App.handleBought);
    $(document).on('click', '.btn-withdraw', App.handleWithdraw);
  },

  render: async function (buyers, account) {

    let crt = await App.contracts.Cryptomon.deployed();

    // Display account number
    web3.eth.getAccounts( (error, accounts) =>
    {
      if (error) {
        console.error(error);
      }
      document.getElementById("account-num").textContent = accounts[0];
    })

    // Display balance owed by contract
    let balanceOwed = web3.fromWei(await crt.checkBalance.call());
    document.getElementById("balance").textContent = balanceOwed;

    // Get species index to text conversions
    let data = await $.getJSON('../pokemon.json');

    // Render cards
    var pokRow = $('#pokRow');
    var pokTemplate = $('#pokTemplate');
    let numPok = await crt._totalNumPokemon.call();
    for (let id = 0; id < numPok; id++) {
      // id, gen, species, type, lvl, 1st evo, next evo

      // id
      pokTemplate.find('.pok-id').text(id);

      let speciesId = parseInt(await crt._pokSpeciesId.call(id));
      console.log(speciesId);
      pokTemplate.find('.panel-title').text(data[speciesId].name);
      pokTemplate.find('.pok-type').text(data[speciesId].type);
      pokTemplate.find('.pok-evolves-to').text(data[speciesId].evolvesTo);
      pokTemplate.find('.pok-breeds-to').text(data[speciesId].breedsTo);
      pokTemplate.find('img').attr('src', data[speciesId].picture);


      // TODO: use these instead?
      // let typeId = parseInt(await crt._speciesType.call(speciesId));
      // let firstEvoId = parseInt(await crt._speciesBreedsTo.call(speciesId));
      // let nextEvoId = parseInt(await crt._speciesEvolvesTo.call(speciesId));

      let gen = parseInt(await crt._pokGeneration.call(id));
      pokTemplate.find('.pok-generation').text(gen);

      let level = parseInt(await crt._pokLevel.call(id));
      pokTemplate.find('.pok-level').text(level);

      let timesCanBreed = parseInt(await crt._pokTimesCanBreed.call(id));
      pokTemplate.find('.pok-times-can-breed').text(timesCanBreed);

      let price = web3.fromWei(await crt._pokPrice.call(id));
      pokTemplate.find('.pok-buy-price').text(price);
      
      pokRow.append(pokTemplate.html());
    }

    // from init()
    // for (i = 0; i < data.length; i++) {
    //   pokTemplate.find('.panel-title').text(data[i].name);
    //   pokTemplate.find('.pok-type').text(data[i].type);
    //   pokTemplate.find('.pok-level').text(data[i].age);
    //   pokTemplate.find('.pok-evolves-to').text(data[i].evolvesTo);
    //   pokTemplate.find('.btn-buy').attr('data-id', data[i].id);

    // };


    // old stuff
    // var cryptomonInstance;

    // web3.eth.getAccounts(function (error, accounts) {
    //   if (error) {
    //     console.log(error);
    //   }

    //   var account = accounts[0];

    //   let contract = App.contracts.Cryptomon.deployed();

    //   contract.then(function (instance) {
    //     return instance.getPrices.call();
    //   }).then(function (prices) {
    //     for (i = 0; i < prices.length; i++) {
    //       let price = web3.fromWei(parseInt(prices[i]), 'ether');
    //       console.log(price);
    //       let buttonText = "Buy (" + price + " ETH)";
    //       $('.panel-pokemon').eq(i).find('button').text(buttonText);
    //     }
    //   }).catch(function (err) {
    //     console.log(err.message);
    //   });

    //   contract.then(function (instance) {
    //     return instance.getOwners.call();
    //   }).then(function (owners) {
    //     for (i = 0; i < owners.length; i++) {
    //       if (owners[i] == account) {
    //         $('.panel-pokemon').eq(i).find('button').text("Owned").attr('disabled', true);
    //       }
    //     }
    //   }).catch(function (err) {
    //     console.log(err.message);
    //   });
    // });

  },

  handleBought: function (event) {

    event.preventDefault();

    var pokemonId = parseInt($(event.target).data('id'));

    var cryptomonInstance;

    web3.eth.getAccounts((error, accounts) => {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Cryptomon.deployed().then(function (instance) {
        cryptomonInstance = instance;

        // Execute purchase as a transaction by sending account
        return cryptomonInstance.price(pokemonId).then(function (price) {
          console.log(parseInt(price));
          return cryptomonInstance.buyPokemon(pokemonId, { from: account, value: parseInt(price) });
        })
      }).then(function (result) {
        return App.markBought();
      }).catch(function (err) {
        console.log(err.message);
      });
    });
  },

  handleWithdraw: async function (event) {
    event.preventDefault();

    let crt = await App.contracts.Cryptomon.deployed();
    await crt.withdrawFunds.sendTransaction();
  }

};

$(function () {
  $(window).load(function () {
    App.init();
  });
});
