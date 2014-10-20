public with sharing class sObjectWrapper {
  public String id {get; set;}
  public String name {get; set;}
  
  public sObjectWrapper(String i, String n){
    id = i;
    name = n;
  }
}