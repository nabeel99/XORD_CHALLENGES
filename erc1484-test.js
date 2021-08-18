const {expect} = require('chai');

describe("Erc1484 contract testing", ()=>{

    let token,hardhat;
    let ownr,addr1,addr2,addr3;
    beforeEach(async ()=>{

        token = await ethers.getContractFactory('erc1484');
        hardhat = await token.deploy();
        await hardhat.deployed();
        [ownr,addr1,addr2,addr3] = await ethers.getSigners();
        await hardhat.connect(addr1).createIdentity(addr1.address,
            [ownr.address,addr2.address],
            [ownr.address,addr2.address]);

});
    describe("testing identity related features",() =>{
        it('testing IdentityExist true', async ()=> {
            expect( await hardhat.identityExists(1)).to.equal(true);

        });
        it('testing Identity exist fails', async ()=> {
             expect( await hardhat.identityExists(2)).to.equal(false);

        });
        it('testing hasIdentity true', async ()=> {
            expect( await hardhat.hasIdentity(addr1.address)).to.equal(true);

        });
        it('testing hasIdentity false', async ()=> {
            expect( await hardhat.hasIdentity(addr2.address)).to.equal(false);

        });
        it('testing getein true',async ()=>{
            expect(await hardhat.getEIN(addr1.address)).to.equal(1);

        })
        it('testing getein false',async ()=>{
            await expect( hardhat.getEIN(addr2.address)).to.be.reverted;

        })

       
    });
    describe('testing associated address, resolver,provider features',()=>{

        it('testing isassociated true',async ()=>{
            expect(await hardhat.isAssociatedAddressFor(1,addr1.address)).to.equal(true);

        });
        it('testing isassociated false',async ()=>{
            await expect( hardhat.isAssociatedAddressFor(1,addr2.address)).to.be.reverted;

        });
        it('testing isProvider true',async ()=>{
            expect(await hardhat.isProviderFor(1,ownr.address)).to.equal(true);

        });
        it('testing isProvider false',async ()=>{
           await expect( hardhat.isProviderFor(1,addr1.address)).to.be.reverted;

        });
        it('testing isResolver true',async ()=>{
            expect(await hardhat.isResolverFor(1,ownr.address)).to.equal(true);

        });
        it('testing isResolver false',async ()=>{
           await expect( hardhat.isResolverFor(1,addr1.address)).to.be.reverted;

        });
       

    })


    describe('identity creation testing',()=>{
        it('check getIdentity',async ()=>{
            console.log(await hardhat.getIdentity(1));


        });

        it('createIdentity emitter',async ()=>{
            await expect( hardhat.createIdentity(ownr.address,
                [addr1.address,addr2.address],
                [addr1.address,addr2.address]) ).to.emit(hardhat, 'IdentityCreated').withArgs(ownr.address,2,ownr.address,ownr.address, [addr1.address,addr2.address],
                    [addr1.address,addr2.address],false);
        });
        
    })
    describe('signature testing',()=>{
        let msgbytes,sig,claimedSig,sig2,claimedSig2;
        beforeEach(async ()=>{
             msgbytes = await ethers.utils.arrayify(ethers.utils.id("I authorize creation of this Identity"));
             sig = await ownr.signMessage(msgbytes);
             claimedSig = await ethers.utils.splitSignature(sig);
             sig2 = await addr1.signMessage(msgbytes);
             claimedSig2 = await ethers.utils.splitSignature(sig2);


        })

        it('getting signature',async()=>{
       
            await expect( hardhat.createIdentityDelegated(
                ownr.address, ownr.address, 
                [addr1.address,addr2.address],
                [addr1.address,addr2.address],
                claimedSig.v,claimedSig.r,claimedSig.s, 2) ).to.emit(hardhat,'IdentityCreated').withArgs(ownr.address,2,ownr.address,ownr.address, [addr1.address,addr2.address],
                    [addr1.address,addr2.address],true);

        });
        it('adding associate address',async ()=>{

            await expect(hardhat.connect(addr1).addAssociatedAddress(
                addr1.address, ownr.address,
                claimedSig.v, claimedSig.r, claimedSig.s, 
                 2)).to.emit(hardhat,'AssociatedAddressAdded').withArgs(addr1.address,1,addr1.address,ownr.address);

        })
        it('adding  delegatedassociate address',async ()=>{

            await expect(hardhat.connect(addr1).addAssociatedAddressDelegated(
                addr1.address, ownr.address,
                [claimedSig2.v,claimedSig.v], [claimedSig2.r,claimedSig.r], [claimedSig2.s,claimedSig.s], 
                 [2,1])).to.emit(hardhat,'AssociatedAddressAdded').withArgs(addr1.address,1,addr1.address,ownr.address);

                
        })
        it('triggeringRecovery',async ()=>{
         //   console.log(addr1.address);

            await expect(hardhat.connect(addr1).triggerRecovery(1, 
                ownr.address, claimedSig.v, claimedSig.r, claimedSig.s, 
                1) ).to.emit(hardhat,'RecoveryTriggered').withArgs(addr1.address,1,[addr1.address],ownr.address);
        });
        it("triggerDestruction", async  () => {
            await expect( hardhat.connect(addr1).triggerDestruction(1,[],[],true)).to.emit(
              hardhat,"IdentityDestroyed").withArgs(addr1.address,1,addr1.address,true);
          });
        
    })



});
