import { LightningElement} from 'lwc';
import basePath from '@salesforce/community/basePath';
import LBL_SESSION_TIMEOUT from '@salesforce/label/c.ECOM_Session_Timeout_Cookie';
import ECOM_Session_Time_Out_Minutes from '@salesforce/label/c.ECOM_Session_Time_Out_Minutes';

export default class Ecom_sessionTimeoutRedirect extends LightningElement {

      labels = {
        LBL_SESSION_TIMEOUT,
        ECOM_Session_Time_Out_Minutes
      }

    intervalId;
    inactivityTimer;
    showPopup = false;
    domainName = '.revvity.com';
    connectedCallback() {
        // Start checking every 5 seconds
        this.intervalId = setInterval(() => {
            this.checkCookieTime();
        }, 5000);
    }

    disconnectedCallback() {
        // Clear interval when component is destroyed
         clearInterval(this.intervalId);
         clearTimeout(this.inactivityTimer);
    }

    handleContinue(){
         this.showPopup = false;
         clearTimeout(this.inactivityTimer);
         this.updateTimestamp();
         this.intervalId = setInterval(() => {
            this.checkCookieTime();
        }, 5000);
    }

    handleLogout(){
         this.showPopup = false;
         this.redirectToLogin();
    }

    updateTimestamp() {
       let cookieName = this.labels.LBL_SESSION_TIMEOUT;
       const secondsTimestamp = Math.floor(Date.now() / 1000);
       this.setCookie(cookieName, secondsTimestamp, 1);
    }

     setCookie(name, value, days) {
        let expires = "";
        if (days) {
            const date = new Date();
            // 2025 Standard: Ensure expiry is calculated accurately
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            expires = "; expires=" + date.toUTCString();
        }

        // Updated with domain attribute
        document.cookie = `${name}=${value}${expires}; path=/; domain=${this.domainName}; SameSite=Lax; Secure`;
        
        console.log(`Cookie ${name} updated for domain ${this.domainName}`);
    }


    checkCookieTime() {
        // Get the cookie value
        const cookieName = this.labels.LBL_SESSION_TIMEOUT;
        const cookieValue = this.getCookie(cookieName);
        if (cookieValue) {
           const cookieTimestamp = parseInt(cookieValue, 10); // Convert to number
           const currentTimestamp = Math.floor(Date.now() / 1000); // Convert to seconds

            // Check if 25 minutes have passed
            const timeDifference = currentTimestamp - cookieTimestamp;
            const diffMinutes = Math.floor(timeDifference / 60);
            const timeoutMinutes =  this.labels.ECOM_Session_Time_Out_Minutes;
           if (Math.floor(diffMinutes) == Math.floor(timeoutMinutes)) {
                this.showPopup = true;
                clearInterval(this.intervalId); // Stop further checks after alert
                // Start 5-minute inactivity timer
                this.inactivityTimer = setTimeout(() => {
                    this.handleLogout();
                }, 5 * 60 * 1000);   
            }
         
        }
    }

    getCookie(name) {
        const value = `; ${document.cookie}`;
        const parts = value.split(`; ${name}=`);
        if (parts.length === 2) return parts.pop().split(';').shift();
        return null;
    }
    
    redirectToLogin() {
         window.location.href = `${basePath}/secur/logout.jsp?retUrl=${basePath}/login?ptcms=true`;
    }

    handleClose(){
      this.redirectToLogin();  
    }
}