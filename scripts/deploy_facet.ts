import { ethers } from "hardhat";
import { FacetCutAction, getSelectors } from "./libraries/diamond";

const DiamondAddress = "0xefeC53f0F5F966947a7d74e7283E19Df4F57A720";
const deployFacets = async () => {
  const accounts = await ethers.getSigners();
  const facets = [];
  // deploy facets
  const Facet = await ethers.getContractFactory("P0Facet");
  const facet = await Facet.deploy();
  await facet.waitForDeployment();
  console.log(`P0Facet deployed: ${await facet.getAddress()}`);
  facets.push(facet);

  cutFacets(facets, FacetCutAction.Add);
};

const removeFacets = async () => {
  const accounts = await ethers.getSigners();
  const facets = [];
  const Facet = await ethers.getContractFactory("P0Facet");
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
    DiamondAddress
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

const searchFacets = async () => {
  const DiamondLoupeFacet = await ethers.getContractAt(
    "DiamondLoupeFacet",
    DiamondAddress
  );

  const facets = await DiamondLoupeFacet.facets();
  console.log(facets);
};
// removeFacets();
// deployFacets();
// searchFacets();
