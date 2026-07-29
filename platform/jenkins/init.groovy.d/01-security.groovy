import hudson.security.FullControlOnceLoggedInAuthorizationStrategy
import hudson.security.HudsonPrivateSecurityRealm
import jenkins.install.InstallState
import jenkins.model.Jenkins

def jenkins = Jenkins.get()
def adminId = System.getenv('JENKINS_ADMIN_ID')
def adminPassword = System.getenv('JENKINS_ADMIN_PASSWORD')

if (!adminId || !adminPassword) {
    throw new IllegalStateException(
        'JENKINS_ADMIN_ID and JENKINS_ADMIN_PASSWORD must be configured'
    )
}

if (!(jenkins.securityRealm instanceof HudsonPrivateSecurityRealm)) {
    jenkins.securityRealm = new HudsonPrivateSecurityRealm(false)
}

def realm = (HudsonPrivateSecurityRealm) jenkins.securityRealm
if (jenkins.getUser(adminId) == null) {
    realm.createAccount(adminId, adminPassword)
}

def authorization = new FullControlOnceLoggedInAuthorizationStrategy()
authorization.setAllowAnonymousRead(false)
jenkins.authorizationStrategy = authorization
jenkins.installState = InstallState.INITIAL_SETUP_COMPLETED
jenkins.save()
