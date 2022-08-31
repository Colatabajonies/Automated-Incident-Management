global class AIM_ScheduledFlowRun implements Schedulable
{
    public List<String> flowDetails;
    
    global void execute(SchedulableContext SC) 
    {
        //System.debug(LoggingLevel.ERROR, flowDetails );
        
        Flow.Interview.createInterview(flowDetails[0], flowDetails[1], new Map<String,Object>()).start();
        
        //Remove the schedule and create a new one
        string theName = 'fsched-' + flowDetails[1] + '%';
        List<CronTrigger> JOBIDLIST = new List<CronTrigger>([select id from CronTrigger where CronJobDetail.Name LIKE: theName]);
        for(CronTrigger job : JOBIDLIST)
        {
            System.abortJob(job.id);
        }

        //Now Schedule the next run
        Datetime nextRun = Datetime.now();
        if (flowDetails[2] == 'minute')
        {
            nextRun = nextRun.addMinutes(Integer.valueOf(flowDetails[3]));
        }
        else if (flowDetails[2] == 'hour')
        {
            nextRun = nextRun.addHours(Integer.valueOf(flowDetails[3]));
        }
        else 
        {
            return;    
        }
        System.schedule('fsched-' + flowDetails[1], '0 ' + String.valueOf(nextRun.minute()) + ' ' + String.valueOf(nextRun.hour()) + ' ' + String.valueOf(nextRun.day()) + ' ' + String.valueOf(nextRun.month()) + ' ? ' + String.valueOf(nextRun.year()), new AIM_ScheduledFlowRun(flowDetails));
        
    }
    
    public AIM_ScheduledFlowRun ( List<String> aflowDetails) 
    {
        if ( flowDetails == null ) {
            flowDetails = aflowDetails;
        } else {
            flowDetails.addAll(aflowDetails);
        }
    }
}