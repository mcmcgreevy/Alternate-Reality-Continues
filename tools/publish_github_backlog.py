"""Publish the reviewed planning baseline. Uses Git credentials in memory only.
Reruns reuse stable issue IDs and existing milestones; they never duplicate a plan.
"""
from pathlib import Path
import json, re, subprocess, time, urllib.request, urllib.error
REPO='mcmcgreevy/Alternate-Reality-Continues'
API='https://api.github.com'
BASE=f'/repos/{REPO}'
MARKER='<!-- ar-planning-baseline-2026-11-17 -->'
ROOT=Path(__file__).resolve().parents[1]

def credentials():
    result=subprocess.run(['git','credential','fill'],input='protocol=https\nhost=github.com\n\n',text=True,capture_output=True,check=True)
    values=dict(line.split('=',1) for line in result.stdout.splitlines() if '=' in line)
    return values['password']

def request(path, method='GET', payload=None):
    req=urllib.request.Request(API+path, data=None if payload is None else json.dumps(payload).encode(),method=method,headers={'Authorization':'Bearer '+TOKEN,'Accept':'application/vnd.github+json','Content-Type':'application/json','User-Agent':'Alternate-Reality-planning','X-GitHub-Api-Version':'2022-11-28'})
    with urllib.request.urlopen(req,timeout=40) as response:
        result=json.load(response)
    if method!='GET': time.sleep(1.1)
    return result

def pages(path):
    result=[]
    for page in range(1,30):
        data=request(path+('&' if '?' in path else '?')+f'per_page=100&page={page}')
        result.extend(data)
        if len(data)<100:return result
    raise RuntimeError('Pagination exceeded safe limit')

def source_links(text):
    return re.sub(r'\]\(\.\./assets/documentation/kroah-city-st-v2/(\w+)\.html\)',r'](http://bringerp.free.fr/RE/Ar/\1.php5)',text)

def build():
    backlog=(ROOT/'docs/BACKLOG.md').read_text(encoding='utf-8')
    epics=[];features=[];stories=[]
    for epic in re.finditer(r'^## (E\d+) — ([^\n]+)\n(.*?)(?=^## |\Z)',backlog,re.M|re.S):
        eid,title,body=epic.groups()
        area={'E01':'infrastructure','E02':'world','E03':'character','E04':'encounters','E05':'establishments','E06':'dungeon','E07':'presentation'}[eid]
        epics.append(dict(key=eid,title=f'[{eid}] {title}',body=body.split('### ')[0].strip(),kind='epic',area=area))
        for feature in re.finditer(r'^### (F\d+) — ([^\n]+)\n(.*?)(?=^### |\Z)',body,re.M|re.S):
            fid,name,content=feature.groups()
            phase=re.search(r'Milestone: (M\d)',content)[1]
            coverage=re.search(r'Coverage: ([^·\n]+)',content)[1].strip()
            story_matches=list(re.finditer(r'\*\*(S\d+):\*\* (.*?)(?=\*\*S\d+:\*\*|\Z)',content,re.S))
            meta=content.split('**S')[0].strip()
            features.append(dict(key=fid,title=f'[{fid}] {name}',body=source_links(content.strip()),parent=eid,kind='feature',area=area,phase=phase,coverage=coverage))
            for match in story_matches:
                sid,story=match.groups()
                suffix=' — storyboard and attribution' if sid=='S26' else (' — playback, skip and replay' if sid=='S27' else '')
                stories.append(dict(key=sid,title=f'[{sid}] {name}{suffix}',body=source_links(meta)+'\n\n'+story.strip(),parent=fid,kind='story',area=area,phase=phase,coverage=coverage))
    assert (len(epics),len(features),len(stories))==(7,26,32)
    return epics+features+stories

def main():
    items=build()
    existing=pages(BASE+'/issues?state=all')
    matches={}
    for issue in existing:
        if 'pull_request' in issue: continue
        key=re.match(r'\[([EFS]\d+)\]',issue['title'])
        if key:
            if MARKER not in (issue['body'] or ''):raise RuntimeError('Unrelated issue uses planned ID '+key[1])
            matches[key[1]]=issue
    print(f'Existing repository issues: {len(existing)}; reusable planning issues: {len(matches)}',flush=True)
    label_specs={
       'planning:baseline':('5319e7','Reviewed reconstruction backlog'),
       'status:backlog':('ededed','Needs refinement before implementation'),
       **{f'kind:{k}':('7057ff',f'Planning hierarchy: {k}') for k in ['epic','feature','story','research','bug']},
       **{f'area:{a}':('0075ca',f'System area: {a}') for a in ['infrastructure','world','character','encounters','establishments','dungeon','presentation']},
       **{f'coverage:{c.lower().replace(" ","-")}':('fbca04',f'Current implementation coverage: {c}') for c in ['Scaffold','Partial','Prototype','Not built']}
    }
    labels={label['name'] for label in pages(BASE+'/labels')}
    for name,(color,description) in label_specs.items():
        if name not in labels:request(BASE+'/labels','POST',dict(name=name,color=color,description=description))
    milestones={m['title']:m for m in pages(BASE+'/milestones?state=all')}
    phase_numbers={}
    roadmap=(ROOT/'docs/ROADMAP.md').read_text(encoding='utf-8')
    for line in roadmap.splitlines():
        if not re.match(r'\| M[1-5] ',line):continue
        title,scope,criteria,deps=[cell.strip() for cell in line.split('|')[1:-1]]
        phase=title[:2]
        if title not in milestones:
            milestones[title]=request(BASE+'/milestones','POST',{'title':title,'description':f'Scope: {scope}\n\nExit criteria: {criteria}\n\nDepends on: {deps}\n\nNo date committed. Broad features can span phases; this is their initial delivery phase.'})
        phase_numbers[phase]=milestones[title]['number']
    for item in items:
        key=item['key']
        if key in matches:continue
        labels=['planning:baseline','status:backlog','kind:'+item['kind'],'area:'+item['area']]
        if item.get('coverage'):labels.append('coverage:'+item['coverage'].lower().replace(' ','-'))
        body=MARKER+'\n\n'+item['body']
        if item.get('parent'):body='Parent: #'+str(matches[item['parent']]['number'])+'\n\n'+body
        body+='\n\n### Workflow\n\nBacklog: refine into small, testable work before implementation. City rules follow Kroah’s Atari ST City v2.0 research; Dungeon geography retains verified 8-bit provenance. Existing coverage does not mean fidelity complete.\n\nBefore Ready: identify exact source sections, dependencies, uncertainties and acceptance examples. Before Done: pass relevant checks, exercise integrated behavior, preserve/migrate saves and update code/source notes.'
        payload=dict(title=item['title'],body=body,labels=labels)
        if item.get('phase'):payload['milestone']=phase_numbers[item['phase']]
        matches[key]=request(BASE+'/issues','POST',payload)
        print(f"Created {key}: {matches[key]['html_url']}",flush=True)
    for item in items:
        parent=item.get('parent')
        if not parent:continue
        endpoint=BASE+f"/issues/{matches[parent]['number']}/sub_issues"
        children=pages(endpoint)
        if matches[item['key']]['id'] not in [child['id'] for child in children]:
            request(endpoint,'POST',{'sub_issue_id':matches[item['key']]['id']})
        print(f"Linked {parent} -> {item['key']}",flush=True)
    overview=next((i for i in existing if i['title']=='Development roadmap and backlog index' and MARKER in (i['body'] or '')),None)
    overview_body=MARKER+'\n\n'+roadmap.replace('[BACKLOG.md](BACKLOG.md)','the epic hierarchy below').replace('[SOURCE_BASELINE.md](SOURCE_BASELINE.md)','the agreed ST City / 8-bit Dungeon baseline')+'\n\n## Epic index\n\n'+ '\n'.join(f"- #{matches[i['key']]['number']}" for i in items if i['kind']=='epic')+'\n\nOpening credits: #'+str(matches['F26']['number'])+' (storyboard/attribution and playback/skip/replay).\n\nGitHub issues are the live status authority. Current planned count: 7 epics, 26 features, 31 stories. Roadmap phases are intentionally undated.'
    if not overview:overview=request(BASE+'/issues','POST',{'title':'Development roadmap and backlog index','body':overview_body,'labels':['planning:baseline']})
    manifest={'repository':REPO,'roadmap_url':overview['html_url'],'milestones':{k:v['html_url'] for k,v in milestones.items()},'issues':{i['key']:{'number':matches[i['key']]['number'],'id':matches[i['key']]['id'],'node_id':matches[i['key']]['node_id'],'url':matches[i['key']]['html_url'],'parent':i.get('parent'),'phase':i.get('phase')} for i in items}}
    (ROOT/'docs/GITHUB_BACKLOG_INDEX.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print('Complete: '+overview['html_url'],flush=True)

if __name__=='__main__':
    TOKEN=credentials()
    try:main()
    except urllib.error.HTTPError as error:
        print('GitHub API error',error.code,error.read().decode()[:1200],flush=True)
        raise SystemExit(1)
