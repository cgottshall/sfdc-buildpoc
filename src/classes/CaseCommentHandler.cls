public class CaseCommentHandler {
	
	public static void handleNewComment(Case C) {
		String Cid;
		String LastComment;
		Case aCase = [SELECT Id, Last_Comment_Added__c, Assignment_Group__c, PTS_ID__c FROM Case WHERE Id = :C.Id];
		try {
			CaseComment aCaseComment = [SELECT Id, CommentBody, CreatedBy.Name, CreatedDate FROM CaseComment 
										WHERE ParentId = :aCase.Id AND CreatedDate = :aCase.Last_Comment_Added__c 
										ORDER BY LastModifiedDate DESC LIMIT 1];
			if(aCaseComment.CommentBody <> '') {
				if(aCase.PTS_ID__c <> null || aCase.Assignment_Group__c == 'Escalation to PTS') {
					String message = 'RECORD ID: '+ aCase.Id +
									 '\nPTS ID: ' + aCase.PTS_ID__c +
									 '\nCOMMENT: ' + aCaseComment.CommentBody + '\n~~~~~~' +
									 '\nCOMMENT BY: ' + aCaseComment.CreatedBy.Name;
					sendMessageToPts('SFDC-PTS: Case Comment Added', message);
				}
			}
		} catch (System.Queryexception qe) {
			System.debug('No comments could be found matching criteria: Parent Case ID ' + aCase.Id + ', CreatedDate ' + aCase.Last_Comment_Added__c);
		}
	}
	
	public static void sendMessageToPts(String subject, String message) {
		Messaging.Singleemailmessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses;
		//Always send a copy of the message to Automated User (if it exists)
		List<User> ptsUser = [SELECT Email FROM User WHERE Username LIKE 'pts@ibsys.com%'];
		if(ptsUser.size() > 0)
			toAddresses = new String[] {ptsUser.get(0).Email,'cgottshall@ibsys.com'};
		else
			toAddresses = new String[] {'cgottshall@ibsys.com'};
		mail.setSubject(subject);
		mail.setToAddresses(toAddresses);
		mail.setPlainTextBody(message+'\n\n\nfrom CaseCommentHandler.sendMessageToPts()');
		mail.setUseSignature(false);
		// Send the email  
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

}