/**
 * Created by JJ93 on 11.09.2020.
 */

public class NegotiationProcess {
    @InvocableMethod(Label='New Task to new Account')
    public static void newTaskToNewAccount(List<AccountToTask> accounts) {

        List<Task> tasksToCreate = new List<Task>();
        List<Task> tasksToReassign = new List<Task>();
        List<Task> allTasks = [SELECT Id FROM Task];
        List<User> activeUsers = [SELECT Id FROM User WHERE IsActive = TRUE];

        for (AccountToTask accountToTask : accounts) {
            List<Task> tasksToCheck = new List<Task>();
            for (Task task : allTasks) {
                if (task.WhatId == accountToTask.accountId) {
                    tasksToCheck.add(task);
                }
            }
            if (tasksToCheck.size() >= 3) {
                for (Task task : tasksToCheck) {
                    task.OwnerId = getRandomUserId(activeUsers);
                }
                tasksToReassign.addAll(tasksToCheck);

            } else {
                tasksToCreate.add(generateNewTask(accountToTask));
            }

        }
        insert tasksToCreate;
        update tasksToReassign;
    }
    private static Id getRandomUserId(List<User> activeUsers) {
        Integer randomUserIndex = Math.round(Math.random() * (activeUsers.size() - 1));
        return activeUsers[randomUserIndex].Id;
    }


    private static Task generateNewTask(AccountToTask accountToTask) {
        Task newTask = new Task();
        newTask.WhatId = accountToTask.accountId;
        newTask.Subject = 'Negotiations with ' + accountToTask.accountName;
        return newTask;

    }
    public class AccountToTask {
        @InvocableVariable(Label='Account ID' Required=true)
        public Id accountId;
        @InvocableVariable(Label='Account Name' Required=true)
        public String accountName;
    }
}
