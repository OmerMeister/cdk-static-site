#!/usr/bin/env python3

import aws_cdk as cdk

from cdk_static_site.cdk_static_site_stack import CdkStaticSiteStack


app = cdk.App()
CdkStaticSiteStack(app, "CdkStaticSiteStack")

app.synth()
