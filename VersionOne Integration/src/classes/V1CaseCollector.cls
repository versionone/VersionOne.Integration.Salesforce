public class V1CaseCollector {

  public static List<Case> getCasesForV1() {
    Group srcQueue = getQueueByName('Escalate to VersionOne');
    if (srcQueue == null){
      return null;
    }
    List<Case> cases = [select id, OwnerId from Case where OwnerId = :srcQueue.Id ];
    System.debug('  Found Cases: ' + cases.size());
    return cases;
  }
  
  public static Group getQueueByName(String name) {
    List<Group> queues = [select Id, Name, Type from Group where Type='Queue' and name = :name];
    if (queues.isEmpty()){
      System.debug('  Cannot find queue: ' + name);
      return null;
    }
    System.debug('  Found Queue: ' + queues[0]);
    return queues[0];
  }
}