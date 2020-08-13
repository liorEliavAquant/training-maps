global with sharing class MapsController {
    @RemoteAction
    global static Id CreateMap(String name, List<List<Integer>> coords) {
        Map__c newMap = new Map__c(Name=name);

        insert newMap;

        List<Map_Cord__c> mapCords = new List<Map_Cord__c>();
        for(Integer[] coord : coords){
            mapCords.add(new Map_Cord__c(Longitude__c =coord[0], Latitude__c=coord[1], Map__c = newMap.Id));
        }
        
        insert mapCords;
        
        return newMap.Id;
    }

    @RemoteAction
    global static Map<String,Object> UpdateMap(Id mapId, String name, List<Map_Cord__c> cordsToAdd, List<Map_Cord__c> cordsToDelete){
        Map__c mapObj = [SELECT Name, (SELECT Latitude__c, Longitude__c FROM Map__c.Map_Cords__r ) FROM Map__c WHERE Id = :mapId LIMIT 1];

        if(name != null){
            mapObj.Name = name;
        }

        if(cordsToDelete != null){
            List<Map_Cord__c> deleteList = new List<Map_Cord__c>();
            for(Map_Cord__c deleteCord: cordsToDelete){
                for(Map_Cord__c existingCord: [Select Longitude__c, Latitude__c from Map_Cord__c WHERE Map__r.Id = :mapId]){
                    if(System.equals(existingCord.Longitude__c, deleteCord.Longitude__c) 
                    && System.equals(existingCord.Latitude__c, deleteCord.Latitude__c)){
                        deleteList.add(existingCord);
                    }
                }
            }
            delete deleteList;
        }

        if(cordsToAdd != null){
            for(Map_Cord__c cord: cordsToAdd){
                cord.Map__c = mapObj.Id;
            }
            insert cordsToAdd;
            mapObj.Map_Cords__r.addAll(cordsToAdd);
        }

        update mapObj;

        return new Map<String,Object>();
    }
    
    @RemoteAction
    global static Map__c GetMap(Id objectId){
        List<Map__c> maps = [SELECT Name, (SELECT Latitude__c, Longitude__c FROM Map__c.Map_Cords__r ) FROM Map__c WHERE Id = :objectId LIMIT 1];
        return maps[0];
    }
}