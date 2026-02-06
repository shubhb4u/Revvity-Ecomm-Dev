public interface ECOM_IQuoteService {
    List<Map<String, Object>> quoteWithLinesOperations(Map<String, Object> quoteWithLineDataMap);
    Map<String, Object> quoteDocumentPdfOperations(Map<String, Object> quoteDocumentPDFMap);
    Map<String, Object> singleQuoteWithLinesOperations(Map<String, Object> singleQuoteWithLinesDataMap);
}