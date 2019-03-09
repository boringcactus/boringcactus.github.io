---
layout: default
title: Email Notifications for SSH Logins From Scratch
---

I just spent a while trying to make this happen, so I'm putting this here so I don't have to redo all that research next time.

### Configuring Email

[This guide from Linode](https://www.linode.com/docs/email/postfix/postfix-smtp-debian7/) explains how to install and configure Postfix, which you'll need.
Be careful, though: when it says `[mail.isp.example]` the `[]` aren't just to indicate placeholders.
You do need a literal `[]` around your hostname in your Postfix configuration.

Also, if your setup is like mine, if you try to send email from `x@<your domain>` to `y@<your domain>`, Postfix will unhelpfully try to deliver it locally.
[This Server Fault answer](https://serverfault.com/a/433305) explains how to tell Postfix to not do that.

If you're really unlucky, you may also need to create local users `x` and `y` (with `useradd -M -N -s /bin/false <username>`).
I did that before I fixed the Postfix config, so fixing the Postfix config may be enough.

### Configuring SSH

Thankfully, by the time you've got the email configuration out of the way, [this guide from VPSInfo](https://www.vpsinfo.com/tutorial/email-alert-ssh-login/) fully explains how to set up SSH to send emails on login.
This will send emails even if no login shell is run on the ssh connection.

Since you need to store your credentials in the Postfix configuration, a sufficiently motivated attacker could probably retrieve them.
As such, if you're using email notifications to detect security breaches, I would suggest not sending them to the same address that they're being sent from.

As a security measure, this is purely reactive; you can know that someone has illegitimately connected, but whatever they're trying to do has already been done.
A proactive measure would be to implement 2FA on SSH logins, as per [this guide from DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04).
