<%@ Page Title="Forget Password" Async="true" Language="C#" MasterPageFile="~/SiteNoMenu.Master" AutoEventWireup="true" CodeBehind="ForgetPassword.aspx.cs" Inherits="PMS.Account.ForgetPassword" %>

<asp:Content ID="HeaderContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .login-layout label {
    margin-bottom: 3px;
    width: 84px;
    text-align:left;
}
        input[type="submit"] {
                   border-radius: 3px;
    font-size: 12px;
    line-height: 1.5;
    padding: 5px 10px;
    background-color: #428bca;
    border-color: #357ebd;
    color: #fff;
    text-align: center;
    vertical-align: middle;
    white-space: nowrap;
    margin-bottom: 0;
    font-weight: normal;
    box-shadow: none;
    text-shadow:none;
    border:0;
    width: 90px;
     height: 33px;
    cursor: pointer;
    display: inline-block;
     -moz-user-select: none;
    background-image: none;
        }
        .toolbar {
            display:none;
        }
    </style>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

        <asp:PasswordRecovery ID="PasswordRecovery1" runat="server"
           
             GeneralFailureText="Your Email dose not exists at this time. Please try again later." 
            QuestionFailureText="Your answer does not match the stored answer. Please try again." 
            UserNameFailureText="We couldn't find that user name. Please try again." Height="154px" OnSendingMail="PasswordRecovery1_SendingMail" >
            <MailDefinition BodyFileName="~/EmailTemplate/CustomMail.txt">
            </MailDefinition>

        </asp:PasswordRecovery>
    
</asp:Content>
