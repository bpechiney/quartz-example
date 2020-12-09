package org.acme.quartz;

import io.quarkus.runtime.StartupEvent;
import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.event.Observes;
import javax.inject.Inject;
import javax.transaction.Transactional;

import io.quarkus.scheduler.Scheduled;
import org.quartz.Job;
import org.quartz.JobBuilder;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.SimpleScheduleBuilder;
import org.quartz.Trigger;
import org.quartz.TriggerBuilder;

@ApplicationScoped
public class TaskBean {

    private Scheduler scheduler;

    @Inject
    public TaskBean(Scheduler scheduler) {
        this.scheduler = scheduler;
    }

    void onStart(@Observes StartupEvent event) throws SchedulerException {
        JobDetail jobDetail = JobBuilder.newJob(MyJob.class)
            .withIdentity("myJob", "myGroup")
            .build();

        Trigger trigger = TriggerBuilder.newTrigger()
            .withIdentity("myTrigger", "myGroup")
            .withSchedule(
                SimpleScheduleBuilder.simpleSchedule()
                    .withIntervalInSeconds(10)
                    .repeatForever()
            )
            .startNow()
            .build();
        scheduler.scheduleJob(jobDetail, trigger);
    }

    @Transactional
    void performTask() {
        Task task = new Task();
        task.persist();
    }

    public static class MyJob implements Job {

        @Inject TaskBean taskBean;

        @Override
        public void execute(JobExecutionContext jobExecutionContext) throws JobExecutionException {
            taskBean.performTask();
        }
    }
}
