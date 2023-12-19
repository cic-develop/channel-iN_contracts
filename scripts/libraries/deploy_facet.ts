import { ethers } from "hardhat";
import { FacetCutAction, getSelectors } from "./diamond";

const deployFacets = async (_facetName: string, _diamondAddress: string) => {
  const accounts = await ethers.getSigners();
  const facets = [];
  // deploy facets
  const Facet = await ethers.getContractFactory(_facetName);
  const facet = await Facet.deploy();
  await facet.waitForDeployment();
  console.log(`${_facetName} deployed: ${await facet.getAddress()}`);
  facets.push(facet);

  cutFacets(facets, FacetCutAction.Add, _diamondAddress);
};

const removeFacets = async (_facetName: string, _diamondAddress: string) => {
  const accounts = await ethers.getSigners();
  const facets = [];
  const Facet = await ethers.getContractFactory(_facetName);
  const facet = new ethers.Contract(
    ethers.ZeroAddress,
    Facet.interface,
    accounts[0]
  );
  facets.push(facet);

  cutFacets(facets, FacetCutAction.Remove, _diamondAddress);
};

const cutFacets = async (
  facets: any,
  FacetCutAction: any,
  _diamondAddress: string
) => {
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
    _diamondAddress
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

const searchFacets = async (_diamondAddress: string) => {
  const DiamondLoupeFacet = await ethers.getContractAt(
    "DiamondLoupeFacet",
    _diamondAddress
  );

  const facets = await DiamondLoupeFacet.facets();
  console.log(facets);
};

export { deployFacets, removeFacets, searchFacets };
