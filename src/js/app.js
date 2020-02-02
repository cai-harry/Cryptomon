App = {
  web3Provider: null,
  contracts: {},

  init: async function () {
    // Load pets.
    $.getJSON('../pokemon.json', function (data) {
      var petsRow = $('#petsRow');
      var petTemplate = $('#petTemplate');

      for (i = 0; i < data.length; i++) {
        petTemplate.find('.panel-title').text(data[i].name);
        petTemplate.find('img').attr('src', data[i].picture);
        petTemplate.find('.pet-type').text(data[i].type);
        petTemplate.find('.pet-age').text(data[i].age);
        petTemplate.find('.pet-evolves-to').text(data[i].evolvesTo);
        petTemplate.find('.btn-buy').attr('data-id', data[i].id);

        petsRow.append(petTemplate.html());
      }
    });

    return await App.initWeb3();
  },

  initWeb3: async function () {
    // Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable();
      } catch (error) {
        // User denied account access...
        console.error("User denied account access")
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function () {
    $.getJSON('Cryptomon.json', function (data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var CryptomonArtifact = data;
      App.contracts.Cryptomon = TruffleContract(CryptomonArtifact);

      // Set the provider for our contract
      App.contracts.Cryptomon.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the purchased Pokemon
      return App.markBought();
    });

    return App.bindEvents();
  },

  bindEvents: function () {
    $(document).on('click', '.btn-buy', App.handleBought);
  },

  markBought: function (buyers, account) {
    var cryptomonInstance;

    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      let contract = App.contracts.Cryptomon.deployed();

      // contract.then(function (instance) {
      //   return instance.getPrices.call();
      // }).then(function (prices) {
      //   for (i = 0; i < prices.length; i++) {
      //     console.log(prices[i]);
      //     var buttonText = "Buy ({0})".format(prices[i]);
      //     $('.panel-pokemon').eq(i).find('button').text(buttonText);
      //   }
      // }).catch(function (err) {
      //   console.log(err.message);
      // });

      contract.then(function (instance) {
        return instance.getOwners.call();
      }).then(function (owners) {
        for (i = 0; i < owners.length; i++) {
          if (owners[i] == account) {
            $('.panel-pokemon').eq(i).find('button').text("Owned").attr('disabled', true);
          }
        }
      }).catch(function (err) {
        console.log(err.message);
      });
    });

  },

  handleBought: function (event) {

    event.preventDefault();

    var pokemonId = parseInt($(event.target).data('id'));

    var cryptomonInstance;

    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Cryptomon.deployed().then(function (instance) {
        cryptomonInstance = instance;

        // Execute purchase as a transaction by sending account
        return cryptomonInstance.price(pokemonId).then(function(price){
          console.log(parseInt(price));
          return cryptomonInstance.buyPokemon(pokemonId, { from: account , value: parseInt(price)});
        })
      }).then(function (result) {
        return App.markBought();
      }).catch(function (err) {
        console.log(err.message);
      });
    });
  }

};

$(function () {
  $(window).load(function () {
    App.init();
  });
});
