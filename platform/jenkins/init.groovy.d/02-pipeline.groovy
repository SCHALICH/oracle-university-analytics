import hudson.plugins.git.BranchSpec
import hudson.plugins.git.GitSCM
import hudson.plugins.git.UserRemoteConfig
import jenkins.model.Jenkins
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import org.jenkinsci.plugins.workflow.job.WorkflowJob

def jenkins = Jenkins.get()
def jobName = 'oracle-university-analytics'

if (jenkins.getItem(jobName) == null) {
    def remote = new UserRemoteConfig(
        'https://github.com/SCHALICH/oracle-university-analytics.git',
        null,
        null,
        null
    )
    def scm = new GitSCM(
        [remote],
        [new BranchSpec('*/main')],
        false,
        [],
        null,
        null,
        []
    )
    def job = jenkins.createProject(WorkflowJob, jobName)
    job.definition = new CpsScmFlowDefinition(scm, 'Jenkinsfile')
    job.save()
    job.scheduleBuild2(5)
}
