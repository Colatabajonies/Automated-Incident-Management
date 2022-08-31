public class AIM_CreateFlowSchedule 
{
    @InvocableMethod(label='Create Flow Run Schedule')
    public static List<Boolean> setSchedule(List<setScheduleRequest> requests) 
    {
        for (setScheduleRequest request : requests)
        {
            string namespace = '';
            if (string.isblank(request.flowNamespace))
            {
                namespace = request.flowNamespace;
            }
            
            //First delete all the cron jobs that are of a certain type
            string theName = 'fsched-' + request.flowAPIName + '%';
            List<CronTrigger> JOBIDLIST = new List<CronTrigger>([select id from CronTrigger where CronJobDetail.Name LIKE: theName]);
            for(CronTrigger job : JOBIDLIST)
            {
                System.abortJob(job.id);
            }

            if (String.IsNotBlank(request.hourmin) && request.freq > 0)
            {
                List<String> flowDetails = new List<String>{namespace, request.flowAPIName, request.hourmin, String.valueof(request.freq)};

                //Create new job to run the next minute
                Datetime nextRun = Datetime.now().addMinutes(1);
                System.schedule('fsched-' + flowDetails[1], '0 ' + String.valueOf(nextRun.minute()) + ' ' + String.valueOf(nextRun.hour()) + ' ' + String.valueOf(nextRun.day()) + ' ' + String.valueOf(nextRun.month()) + ' ? ' + String.valueOf(nextRun.year()), new AIM_ScheduledFlowRun(flowDetails));
            }
            
            //Next Create all the new Jobs
            /*if (request.hourmin == 'minute')
            {
                for (integer i = 0; i < 60; i++)
                {
                    if (Math.mod(i, request.freq) == 0)
                    {
                        System.schedule('fsched-' + request.flowAPIName + '_' + string.valueof(i).leftPad(2,'0'), '0 ' + i + ' * * * ?', new AIM_ScheduledFlowRun(new List<String>{namespace, request.flowAPIName}));
                    }
                }
            }
            else if (request.hourmin == 'hour')
            {
                for (integer i = 0; i < 24; i++)
                {
                    if (Math.mod(i, request.freq) == 0)
                    {
                        System.schedule('fsched-' + request.flowAPIName + '_' + string.valueof(i).leftPad(2,'0'), '0 0 ' + i + ' * * ?', new AIM_ScheduledFlowRun(new List<String>{namespace, request.flowAPIName}));
                    }
                }
            } */
        }
        return new List<Boolean>{true};
    }
    
    public class setScheduleRequest
    {
        @InvocableVariable(label='Flow API Name' required=true)
        public string flowAPIName;
        
        @InvocableVariable(label='Flow Namespace')
        public string flowNamespace;
       
        @InvocableVariable(label='Hours or Minutes')
        public string hourmin;
          
        @InvocableVariable(label='Frequency')
        public Integer freq;
    }
}