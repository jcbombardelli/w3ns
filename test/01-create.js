const truffleAssert = require('truffle-assertions');
const W3ns = artifacts.require('W3NS');

const {
    decimals,
    ether,
    addressZero,
    owner1,
    owner2,
    owner3,
    owner4,
    owner5,
    nonowner1,
    nonowner2,
    tld,
    domain
  } = require('./00-datatest.js');


  contract('W3NS', function() {

    let w3ns
  
    beforeEach('setup for each test', async () => {
        w3ns = await W3ns.new()
    })

    describe('Create - owner', function () {
        it('check if creator is owner at create', async() => {           
            var response = await w3ns.owner(owner1)
            assert.equal(response, true, 'owner is wrong at create')
        }) 
    });
})