import { ethers } from "hardhat";
import { FacetCutAction, getSelectors } from "./libraries/diamond";

const deployFacets = async () => {
  const accounts = await ethers.getSigners();
  const facets = [];

  // deploy facets
  const Facet = await ethers.getContractFactory("RubyonFacet");
  const facet = await Facet.deploy();
  await facet.waitForDeployment();
  console.log(`RubyonFacet deployed: ${await facet.getAddress()}`);
  facets.push(facet);

  cutFacets(facets, FacetCutAction.Add);
};

const removeFacets = async () => {
  const accounts = await ethers.getSigners();
  const facets = [];
  const Facet = await ethers.getContractFactory("RubyonFacet");
  const facet = new ethers.Contract(
    ethers.ZeroAddress,
    Facet.interface,
    accounts[0]
  );
  facets.push(facet);

  cutFacets(facets, FacetCutAction.Remove);
};

const cutFacets = async (facets: any, FacetCutAction: any) => {
  const accounts = await ethers.getSigners();
  let cut = [];
  for (const facet of facets) {
    cut.push({
      facetAddress: await facet.getAddress(),
      action: FacetCutAction,
      functionSelectors: getSelectors(facet),
    });
  }

  // upgrade diamond with facets
  const diamondCut = await ethers.getContractAt(
    "IDiamondCut",

    // diamond address
    "0xfaf7D640b3E671095a5F6251a7f46eaB307F7C09"
  );

  let tx;

  tx = await diamondCut.diamondCut(cut, ethers.ZeroAddress, "0x", {
    gasLimit: 8000000,
  });
  let receipt = await tx.wait();
  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`);
  }
  console.log("Completed diamond cut");
};

// removeFacets();
deployFacets();
