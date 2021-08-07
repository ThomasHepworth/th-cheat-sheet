## Acquiring your key_id and secret_key

Amazon's instructions can be found here - https://supsystic.com/documentation/id-secret-access-key-amazon-s3/

## Python Code
```
import boto3
from botocore.client import Config

ACCESS_KEY_ID = '' # enter your access key
ACCESS_SECRET_KEY = '' # enter your secret key
BUCKET_NAME = '' # enter a valid bucket name 

# write a file to s3
def write_to_s3(bucket, file):
    s3 = boto3.resource(
        's3',
        aws_access_key_id=ACCESS_KEY_ID,
        aws_secret_access_key=ACCESS_SECRET_KEY,
        config=Config(signature_version='s3v4')
    )
    # write to s3
    s3.Bucket(bucket).upload_file(file)

    print("Sent files to S3 successfully")

```
