public interface IV1Connector {
    List<String> getClosedDefects();
    String getSourceId();
    Map<String, String> findAllProjects();
    String getDefaultProjectId();
    void createLinkV1ToSF(Integer defectId, String caseId);
    Integer createDefectInVersionOne(Case caseData, String productId, String sourceId);
    Map<String, Boolean> getAlreadyExistedDefects(List<Case> cases);
    Settings getSettings();
}