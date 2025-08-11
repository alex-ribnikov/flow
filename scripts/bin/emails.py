
import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

class Email:

    def __init__(self, _email):
        self.sender_email = "jenkins@nextsilicon.com"
        self.sender_password = os.environ.get('GMAIL_PASSWORD')
        self.recipient_email = _email

    def send_email(self, recipient_email, subject, message):
        """
        Sends an email using an SMTP server (e.g., Gmail).

        :param sender_email: The sender's email address.
        :param sender_password: The sender's email password (or app-specific password).
        :param recipient_email: The recipient's email address.
        :param subject: The subject of the email.
        :param message: The body of the email.
        """
        try:
            # Set up the MIME structure for the email
            msg = MIMEMultipart()
            msg['From'] = self.sender_email
            msg['To'] = recipient_email
            msg['Subject'] = subject
            
            # Attach the body message (plain text)
            msg.attach(MIMEText(message, 'plain'))

            # Set up the SMTP server
            smtp_server = 'smtp.gmail.com'
            smtp_port = 587  # Use 587 for TLS or 465 for SSL

            # Establish connection with the server
            server = smtplib.SMTP(smtp_server, smtp_port)
            server.starttls()  # Secure the connection

            # Login to the email account
            server.login(self.sender_email, self.sender_password)

            # Send the email
            server.sendmail(self.sender_email, recipient_email, msg.as_string())
            server.sendmail(self.sender_email, 'avner.adania@nextsilicon.com', msg.as_string())

            # Close the connection to the SMTP server
            server.quit()

            print(f"Email successfully sent to {recipient_email}")

        except Exception as e:
            print(f"Failed to send email: {e}")
