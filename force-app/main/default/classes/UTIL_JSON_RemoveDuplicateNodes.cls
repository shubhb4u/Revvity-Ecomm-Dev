/**************************************************************
* 1. Jira Ticket(s)
*    -ATEAM-NNNN
*
* 2. Description - This test apex class is used to look for duplicate entries in the child node and consolidate them. Such as duplicate Payers with same Customer Number and address
*
* 3. Objects referenced
*    - No
*
* 4. Callouts to additional Components (including their methods) or None: None
*    
* 5. Dependant Class(es):
*    - None    
*
* 6. Test Class Name: UTIL_JSON_RemoveDuplicateNodes_Test
* 
* 7. Is @Invocable (Yes or No): Yes
*
* 8. Author Name(s): 
*    - BD 2025.01.09 Base
*    - SL 2025.03.19 Added node to copy billTo values to Payer
*
*************************************************************/ 
public with sharing class UTIL_JSON_RemoveDuplicateNodes {
    @InvocableMethod(label='Remove Duplicates' description='Removes duplicate entries from specified child nodes dynamically.')
    public static List<String> removeDuplicates(List<RemoveDuplicatesInput> inputs) {
        // Timestamp: 2025.01.09 - Initializing output list
        List<String> varJSON_output = new List<String>();

        // Timestamp: 2025.01.09 - Looping through each input to process the payload
        for (RemoveDuplicatesInput input : inputs) {
            // Timestamp: 2025.01.09 - Parsing the JSON payload into a generic Map
            Map<String, Object> originalPayload = (Map<String, Object>) JSON.deserializeUntyped(input.payload);

            // Timestamp: 2025.01.09 - Processing each node name specified in the input
            for (String nodeName : input.nodeNames) {
                if (originalPayload.containsKey(nodeName)) {
                    // Timestamp: 2025.01.09 - Extracting the node list for deduplication
                    List<Object> nodeList = (List<Object>) originalPayload.get(nodeName);
                    if (nodeList != null) {
                        // Timestamp: 2025.01.09 - Consolidating duplicates based on rank
                        List<Object> consolidatedNodeList = consolidateNodesByRank(nodeList);
                        // Timestamp: 2025.01.09 - Replacing the original node with the deduplicated list
                        originalPayload.put(nodeName, consolidatedNodeList);
                    }
                }
            }

            // Timestamp: 2025.01.09 - Checking if soldTo is empty and copying shipTo values if necessary
            if (originalPayload.containsKey('soldTo') && ((List<Object>) originalPayload.get('soldTo')).isEmpty()) {
                if (originalPayload.containsKey('shipTo')) {
                    List<Object> shipToList = (List<Object>) originalPayload.get('shipTo');
                    // Copying shipTo values to soldTo
                    originalPayload.put('soldTo', shipToList);
                }
            }
            
            // Timestamp: 2025.03.19 - Checking if payer is empty and copying billTo values if necessary
            if (originalPayload.containsKey('payer') && ((List<Object>) originalPayload.get('payer')).isEmpty()) {
                if (originalPayload.containsKey('billTo')) {
                    List<Object> payerList = (List<Object>) originalPayload.get('billTo');
                    // Copying billTo values to payer
                    originalPayload.put('payer', payerList);
                }
            }

            // Timestamp: 2025.01.09 - Serializing the updated payload back to JSON format
            varJSON_output.add(JSON.serialize(originalPayload));
        }
        // Timestamp: 2025.01.09 - Returning the list of updated JSON payloads
        return varJSON_output;
    }

    private static List<Object> consolidateNodesByRank(List<Object> nodeList) {
        // Timestamp: 2025.01.09 - Initializing a map to store the full nodes keyed by their unique fields
        Map<String, Object> uniqueNodesMap = new Map<String, Object>();

        for (Object rawNode : nodeList) {
            // Timestamp: 2025.01.09 - Deserializing the raw node into a Map to access its fields
            Map<String, Object> node = (Map<String, Object>) rawNode;

            // Timestamp: 2025.01.09 - Creating a unique key based on fields used to identify duplicates
            String uniqueKey = (node.containsKey('customerNumber') ? (String) node.get('customerNumber') : '') + '|' +
                               (node.containsKey('addressFull') ? (String) node.get('addressFull') : '');

            // Timestamp: 2025.01.09 - Determining if this node should replace an existing one based on rank
            if (!uniqueNodesMap.containsKey(uniqueKey) || 
                ((Integer) node.get('rank')) < ((Integer) ((Map<String, Object>) uniqueNodesMap.get(uniqueKey)).get('rank'))) {
                uniqueNodesMap.put(uniqueKey, node);
            }
        }

        // Timestamp: 2025.01.09 - Returning the full, deduplicated list of nodes
        return new List<Object>(uniqueNodesMap.values());
    }

    public class RemoveDuplicatesInput {
        @InvocableVariable(required=true label='Payload' description='The JSON payload in long text format to process.')
        public String payload;

        @InvocableVariable(required=true label='Node Names' description='List of node names to process for duplicates.')
        public List<String> nodeNames;
    }
}