pragma circom 2.0.0;

// Import the hash function MiMCSponge
include "mimcsponge.circom";

template MerkleTree(total_leaves) {
    signal input leaves[total_leaves];
    signal output root;
    var total_nodes = 2*total_leaves-1;
    signal merkle_tree[total_nodes];
    // Position where leaves start
    var start_leaves_pos = total_leaves-1;
    component mimcsponge_components[total_nodes];

    // Go for every node in the merkle tree to compute every hash
    for(var i = total_nodes-1 ; i >= 0; i--) {
        // If it is a leaf, compute the hash of the leaf
        if(i >= start_leaves_pos) {
            mimcsponge_components[i] = MiMCSponge(1, 220, 1);
            mimcsponge_components[i].k <== 0;
            // Input to compute the hash o the leaf
            mimcsponge_components[i].ins[0] <== leaves[i-start_leaves_pos];
        } else {
            // it is not a leaf, compute the hash of the left child with the right child 
            mimcsponge_components[i] = MiMCSponge(2, 220, 1);
            mimcsponge_components[i].k <== 0;
            // Input to compute the hash of the left child
            mimcsponge_components[i].ins[0] <== merkle_tree[2*i+1];
            // Input to compute the hash of the right child
            mimcsponge_components[i].ins[1] <== merkle_tree[2*i+2];
        }
        // Update the merkle tree at position i with the computed hash
        merkle_tree[i] <== mimcsponge_components[i].outs[0];
    }
    // Returns the root, it is in the merkle tree at position 0
    root <== merkle_tree[0];
    
 }
// leaves is a public input signal
component main {public [leaves]} = MerkleTree(4);