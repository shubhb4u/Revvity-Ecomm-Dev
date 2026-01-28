import { LightningElement, api} from 'lwc';
import isGuest from '@salesforce/user/isGuest';
import FORM_FACTOR from '@salesforce/client/formFactor';
import siteId from "@salesforce/site/Id";

//Apex
import loginUser from '@salesforce/apex/ECOM_CustomLoginController.loginUser'

//label
import ECOM_LBL_LOGINTOACCOUNT from '@salesforce/label/c.ECOM_LoginToRevvityAccount';
import ECOM_LBL_SHOWPASSWORD  from '@salesforce/label/c.Ecom_Show_Password';
import ECOM_LBL_EMAILADDRESS  from '@salesforce/label/c.ECOM_EmailAddress';
import ECOM_LBL_PASSWORD  from '@salesforce/label/c.Ecom_Password';
import ECOM_LBL_REMEMBERME  from '@salesforce/label/c.ECOM_RememberMe';
import ECOM_LBL_EMAILISREQUIRED  from '@salesforce/label/c.ECOM_EmailIsRequired';
import ECOM_LBL_PASSWORDISREQUIRED  from '@salesforce/label/c.ECOM_PasswordIsRequired';
import ECOM_LBL_HIDEPASSWORD  from '@salesforce/label/c.Ecom_Hide_Password';
import ECOM_LBL_EMAILADDRESSISNOTVALID  from '@salesforce/label/c.ECOM_EmailAddressIsNotValid';
//import ECOM_LBL_EMAILVALIDATIONREGEX from '@salesforce/label/c.ECOM_EmailValidationRegex';
import ECOM_LBL_CMSBASEURL from '@salesforce/label/c.ECOM_CMSBaseUrl';
import ECOM_LBL_FORWARDFORLOCALE from '@salesforce/label/c.ECOM_IsForwardForLocale';
import ECOM_LBL_COMMUNITYLOCALES from '@salesforce/label/c.ECOM_CommunityLocales';

//import utils
import {getFromLocalStorage, redirectUserIfLocaleNotPresent, setCookie} from 'c/ecom_util';

//static resources
import sres_ECOM_CartIcons from '@salesforce/resourceUrl/ssrc_ECOM_Theme';

const REDIRECT_LOGGEDIN_USER = 'redirectLoggedInUser';
const PREFERRED_LANGUAGE_PREFIX = 'PreferredLanguage';

export default class Ecom_loginCard extends LightningElement {

    constructor(){
        super();
    }



    @api inputCardStyle ='';

    //boolean value
    displayErrorMessage = false;
    isHidePassword=true;
    passwordEmpty = false;
    usernameError = false;

    //text
    errorMessageText='';
    emailErrorMessage;
    passwordValue='';
    usernameErrorMessage = '';
    cardClassStyling = 'ecom-card'

    maxWidthClass = 'ecom-card';

    labels = {
        ECOM_LBL_LOGINTOACCOUNT,
        ECOM_LBL_SHOWPASSWORD,
        ECOM_LBL_EMAILADDRESS,
        ECOM_LBL_PASSWORD,
        ECOM_LBL_REMEMBERME,
        ECOM_LBL_EMAILISREQUIRED,
        ECOM_LBL_PASSWORDISREQUIRED,
        ECOM_LBL_HIDEPASSWORD,
        ECOM_LBL_EMAILADDRESSISNOTVALID,
        //ECOM_LBL_EMAILVALIDATIONREGEX,
        ECOM_LBL_CMSBASEURL,
        ECOM_LBL_FORWARDFORLOCALE,
        ECOM_LBL_COMMUNITYLOCALES
    }

    device = {
        isMobile : FORM_FACTOR==='Small',
        isDesktop : FORM_FACTOR==='Large',
        isTablet :FORM_FACTOR==='Medium'
    }

    images ={
        closeIcon: sres_ECOM_CartIcons + '/img/close-icon.svg',
    }

    get currentMaxWidthClass(){
        let currentClass = 'ecom-card ';
        if(this.isDesktop){
            currentClass = currentClass + 'ecom-max-width-528';
        }
        //console.log('currentMaxWidthClass:: ', currentClass);//Remove after DEV
        return currentClass;
    }

    get cardStyling(){
        let style = this.maxWidthClass + ' ' + this.inputCardStyle;

        return style;
    }

    connectedCallback() {
        const baseURL = window.location.origin;
        //console.log('baseURL:: ', baseURL);//Remove after DEV


        const queryParameters = window.location.search;
        const urlParams = new URLSearchParams(queryParameters);
        //console.log('urlParams:: ', urlParams);//Remove after DEV
        const startURL = urlParams.get('startURL');
        //console.log('startURL::', startURL);//Remove after DEV
        //console.log('startURL::', urlParams.get('test'));//Remove after DEV
        if(((window.location.href.indexOf('builder') == -1 && window.location.href.indexOf('commeditor') == -1)) && !isGuest ) {

            const isRedirectLoggedInUser = getFromLocalStorage(REDIRECT_LOGGEDIN_USER);
            console.log('isRedirectLoggedInUser == true', isRedirectLoggedInUser == 'true');//Remove after DEV
            console.log('login::isRedirectLoggedInUser', isRedirectLoggedInUser);//Remove after DEV
            if((window.location.href.indexOf('builder') == -1 && window.location.href.indexOf('commeditor') == -1) && startURL && startURL != '' && startURL.indexOf('orderDetails') != -1 ){
                //let orderDetails = baseURL + '/login?retURL=' + startURL;//RWPS-1014 - change by VRa Aug 9 2024
                let orderDetails = baseURL + '/login?retUrl=' + startURL;//RWPS-1014 - change by VRa Aug 9 2024
                //console.log('orderDetails::', orderDetails);//Remove after DEV
                //window.location.replace(orderDetails);
            } else if((window.location.href.indexOf('builder') == -1 && window.location.href.indexOf('commeditor') == -1) && isRedirectLoggedInUser == 'true') {
                const dashBoard = baseURL + '/createsession?potype=cmsStoreUser';
                window.location.replace(dashBoard);
            }
        } else {

            if((window.location.href.indexOf('builder') == -1 && window.location.href.indexOf('commeditor') == -1)){
                const dashBoard = baseURL + '/createsession?potype=cmsStoreUser';
                //window.location.replace(dashBoard);
            }

        }

    }

    /**
     * Trigger apex callback to login user
     * @param {*} event
     */
    handleUserLogin(event){
        event.preventDefault();
        const queryParameters = window.location.search;
        const urlParams = new URLSearchParams(queryParameters);
        //console.log('urlParams:: ', urlParams);//Remove after DEV

        //const validationResult = this.validateUserCredentials();
        //validate username and password
        if(this.validateUserCredentials()){

            //fetch user credentials
            const username = this.refs.username;
            const password = this.refs.password

            //const retUrl = urlParams.get('retURL');//RWPS-1014 - change by VRa Aug 9 2024
            const retUrl = urlParams.get('retUrl');//RWPS-1014 - change by VRa Aug 9 2024
            const userLocale = urlParams.get('locale');

            //console.log('username:: ', username.value);//Remove after DEV
            //console.log('password:: ', password.value);//Remove after DEV
            //console.log('retUrl:: ', retUrl);//Remove after DEV
            // Fix for RWPS-2037
            this.refs['loginBtn'].disabled = true;
            // Fix End
            loginUser({
                userName: username.value,
                password: password.value,
                retUrl: retUrl
            }).then(result => {
                //console.log('result:: ', result);//Remove after DEV

                if(result && result.success){
                    this.setErrorData(false, '');

                    if(result.responseData && result.responseData.success){
                        let updatedUrl = result.responseData.storefrontURL;
                        let cookieName = PREFERRED_LANGUAGE_PREFIX + siteId;
                        let locale_user = result?.userRecord?.LocaleSidKey;
                        locale_user = locale_user.replace('_','-');
                        if(locale_user){
                            updatedUrl = updatedUrl + '&locale=' + locale_user;
                        }
                        setCookie(cookieName, locale_user);
                         // RWPS-3306 start Preserve hash in final URL
                        if(retUrl  && retUrl.includes('?')) {
                            // Decode URL-encoded characters
                            const decodedRetUrl = decodeURIComponent(retUrl);
                            const queryParams = decodedRetUrl.split('?')[1];
                            if (queryParams) {
                                updatedUrl += '&' + queryParams;// Keep query params
                            }
                        }// RWPS-3306 end
                        window.location.replace(updatedUrl);
                    } else {
                        this.setErrorData(true, result.responseData.message);
                        // Fix for RWPS-2037
                        this.refs['loginBtn'].disabled = false;
                        // Fix End
                    }
                } else {

                    if(result.message){
                        this.setErrorData(true, result.message);
                    }
                    // Fix for RWPS-2037
                    this.refs['loginBtn'].disabled = false;
                    // Fix End
                }
            }).catch( error =>{
                this.setErrorData(true, 'Something went wrong. Please try again');//TODO
                // Fix for RWPS-2037
                this.refs['loginBtn'].disabled = false;
                // Fix End
                //console.log('error::', error);//Remove after DEV
                //console.log('Login Exception:: ', error);//Remove after DEV
            })


        } else {
            // Fix for RWPS-2037
            this.refs['loginBtn'].disabled = false;
            // Fix End
           // this.usernameErrorMessage = this.labels.ECOM_LBL_EMAILADDRESSISNOTVALID;
           // this.usernameError = true;
          // //console.log('Validation Failed:: ');//Remove after DEV
            return;
        }

    }

    /**
     * This method sets the value for error block
     */
    setErrorData(errorFlag, errorMessage){
        this.displayErrorMessage = errorFlag;
        this.errorMessageText = errorMessage;
    }

    /**
     * Validate if required inputs are provided and email format
     */
    validateUserCredentials(){

        let isValidCredentials = false;

        let isUserNameValidationPassed = false;
        let isPasswordValidationPassed = false;

        const username = this.refs.username;
        const password = this.refs.password;

        if(username && username.value && this.validateEmail() ){
            isUserNameValidationPassed = true;

        } else {
            isUserNameValidationPassed = false;
            this.usernameErrorMessage = this.labels.ECOM_LBL_EMAILADDRESSISNOTVALID;
            this.usernameError = true;
        }

        if (password && password.value && password.value.length > 0 && password.value != '') {
            isPasswordValidationPassed = true;
        } else {
            isPasswordValidationPassed = false;
            this.passwordEmpty = true;
        }

        return isUserNameValidationPassed && isPasswordValidationPassed;
    }

    /**
     *  Validate email format
     * @param {*} userName
     */
    validateEmail(){

        const username = this.refs.username;
        let isValidEmail = false;

        //const mailFormat = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        const mailFormat = '[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$';
        //const mailFormat = String(this.labels.ECOM_LBL_EMAILVALIDATIONREGEX);

        if(username.value.match(mailFormat)){
            isValidEmail = true;
        } else {
            isValidEmail = false;
        }
        //console.log('isValidEmail::', isValidEmail);//Remove after DEV

        return isValidEmail;
    }


    showHidePassword(event){
        let password = this.refs.password.value;

        this.passwordValue = password;
        if(this.isHidePassword){
            this.refs.password.type = 'text';
            this.isHidePassword = false;
        } else {
            this.refs.password.type = 'password';
            this.isHidePassword = true;
        }

    }

    validatePassword(event){
        //console.log('value :: ', event.target.value , 'event.target.value.length::', event.target.value.length);//Remove after DEV
        let value = this.refs.password.value;
        value = value.trim();
        this.refs.password.value = value.trim();
        if(value == '' || value == undefined || value == null) {
            //console.log('passwordEmpty:: ', this.passwordEmpty);//Remove after DEV
            this.passwordValue = value;
            this.passwordEmpty = true;
        } else {

            //console.log('passwordEmpty:: ', this.passwordEmpty);//Remove after DEV
            this.passwordValue = value;
            this.passwordEmpty = false;
        }

        //console.log('passwordEmpty:: ', this.passwordEmpty);//Remove after DEV
    }

    validateUserName(event){

        let username = this.refs.username.value.trim();// event.target.value;
        this.refs.username.value = username;
        //console.log('username ');//Remove after DEV
        //if(username){

            if(username == '' || username == undefined || username == null){
                this.usernameErrorMessage = this.labels.ECOM_LBL_EMAILISREQUIRED;
                this.usernameError = true;
            } else {
                this.usernameErrorMessage = '';
                this.usernameError = false;
            }


       // }

    }


    closePrompt(event){
        this.displayErrorMessage = false;
    }

    redirectToForgotPassword(){
        let baseUrl = window.location.origin;

        const forgotPasswordPage = '/ForgotPassword?ptcms=true';
        window.location.href = baseUrl + forgotPasswordPage;
    }

    // RWPS-3826 start
    handleForgotPWEnter(event) {
        if (event.key === 'Enter' || event.keyCode === 13) {
            this.redirectToForgotPassword();
        }
    }
    // RWPS-3826 end

    handleEnter(event){
        if(event.key === 'Enter' || event.keyCode === 13){ // RWPS-3826
            this.handleUserLogin(event);
        }
    }
}