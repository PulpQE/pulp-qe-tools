"""Migrates issues and comments.
Requires Python 3.6+ and requests.
"""

import json
import time
import requests

# Authentication for user filling issue (must have read/write access to
# repository to add issue to)
USERNAME = 'rochacbruno'
# Personal app token created on github settings page
PASSWORD = ''

# Base constants
BASEURL = 'https://api.github.com/repos/'
REPO_FROM = 'PulpQE/pulp-smash'
REPO_TO = 'PulpQE/Pulp-2-Tests'

# this will migrate only 100 issues per run, there is no pagination implemented
ISSUES_QUERY = '?state=open&per_page=100&labels=pulp2test'

# URLS
GET_ISSUES_URL = f'{BASEURL}{REPO_FROM}/issues{ISSUES_QUERY}'
MAKE_ISSUES_URL = f'{BASEURL}{REPO_TO}/issues'
MAKE_COMMENTS_URL = f'{MAKE_ISSUES_URL}/%s/comments'
CLOSE_ISSUES_URL = f'{BASEURL}{REPO_FROM}/issues/%s'

errors = []


def make_body(item):
    """Make issue body text."""
    body = f"""> Migrated from {item['html_url']}
> author: @{item['user']['login']} - {item['user']['html_url']}
> date created: {item['created_at']}

{item['body']}"""

    return body


def get_github_issues(session):
    """Access github API and get all the issues."""
    issues = []
    resp = json.loads(session.get(GET_ISSUES_URL).content)
    for item in resp:
        data_to_post = {
            'title': item['title'],
            'labels': [label['name'] for label in item['labels']],
            'body': make_body(item)
        }
        issue = {
            'data_to_post': data_to_post,
            'issue': item
        }
        issues.append(issue)
    print(f'Got {len(issues)} issues from {GET_ISSUES_URL}')
    return issues


def get_github_comments(session, item):
    """Get issue comments."""
    if item['comments'] > 0:
        resp = json.loads(session.get(item['comments_url']).content)
        return [{'body': make_body(comment)} for comment in resp]
    return []


def make_github_issue(session, issue, data_to_post):
    """Create an issue on github.com using the given parameters."""
    r = session.post(MAKE_ISSUES_URL, json.dumps(data_to_post))
    new = json.loads(r.content)
    if r.status_code == 201:
        print(
            'Successfully created new Issue "%s" (from old %s)' % (
                new['number'], issue['number']
            )
        )
    else:
        print('Could not create new issue for "%s"' % issue['number'])
        print('Response:', r.content)
    return json.loads(r.content)


def make_github_comment(session, number, comment):
    """Post a new comment."""
    r = session.post(MAKE_COMMENTS_URL % number, json.dumps(comment))
    if r.status_code == 201:
        print('Successfully created Comment for "%s"' % number)
    else:
        print('Could not create comment for Issue "%s"' % number)
        print('Response:', r.content)
    return json.loads(r.content)


def close_github_issue(session, number):
    """Close a github issue."""
    r = session.patch(
        CLOSE_ISSUES_URL % number, json.dumps({'state': 'closed'})
    )
    if r.status_code == 200:
        print('Successfully closed "%s"' % number)
    else:
        print('Could not close "%s"' % number)
        print('Response:', r.content)
    return json.loads(r.content)


class TestResponse:
    """Test response."""

    status_code = 201
    content = '{"number": 1}'


class TestSession:
    """Test session."""
    def __init__(self):
        print("#### RUNNING ON TESTING MODE ####")

    def _dispatch(self, url, body):
        """Print response."""
        print(url)
        print(body)
        return TestResponse()

    patch = post = get = put = delete = _dispatch


if __name__ == '__main__':
    session = requests.Session()
    session.auth = (USERNAME, PASSWORD)

    get_session = session

    post_session = TestSession()  # for testing only

    # post_session = session  # uncomment to make it work

    issues = get_github_issues(get_session)
    for issue in issues:
        print(f'\nProcessing issue {REPO_FROM}/{issue["issue"]["number"]}')
        print('_' * 79)
        try:
            print(issue['issue']['title'], issue['issue']['number'])
            new_issue = make_github_issue(
                post_session, issue['issue'], issue['data_to_post']
            )
            time.sleep(3)
            for comment in get_github_comments(get_session, issue['issue']):
                make_github_comment(post_session, new_issue['number'], comment)
            time.sleep(3)
        except Exception as e:
            print(e)
            errors.append(issue['issue']['number'])
        else:
            close_github_issue(
                post_session,
                issue['issue']['number']
            )

    if errors:
        print(f'The following issues from {REPO_FROM} got errors:')
        print(errors)

    if issues:
        print('Yeahhhh!!! it worked.')
