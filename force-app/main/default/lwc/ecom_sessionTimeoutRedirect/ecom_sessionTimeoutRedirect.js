import { LightningElement} from 'lwc';
import basePath from '@salesforce/community/basePath';

export default class Ecom_sessionTimeoutRedirect extends LightningElement {

    intervalId;
    inactivityTimer;
    showPopup = false;
    
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
    }

    handleLogout(){
         this.showPopup = false;
         this.redirectToLogin();
    }


    checkCookieTime() {
        // Get the cookie value
        const cookieName = 'Drupal.visitor.revvity_auto_login';
        const cookieValue = this.getCookie(cookieName);
        document.cookie = `${cookieName}=${Math.floor(Date.now() / 1000)}; Path=/; SameSite=none`;
        console.log('Timer is running');
        if (cookieValue) {
           const cookieTimestamp = parseInt(cookieValue, 10); // Convert to number
           const currentTimestamp = Math.floor(Date.now() / 1000); // Convert to seconds

            // Check if 25 minutes have passed
            const timeDifference = currentTimestamp - cookieTimestamp;
            const diffMinutes = Math.floor(timeDifference / 60);
            console.log('Time difference', timeDifference);
           if (diffMinutes === 25) {
                 console.log('Entered', timeDifference);
                this.showPopup = true;
                clearInterval(this.intervalId); // Stop further checks after alert
                // Start 5-minute inactivity timer
                this.inactivityTimer = setTimeout(() => {
                    this.redirectToLogin();
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