import io
import os
import sys

path = 'workflow.html'

with open(path, 'r', encoding='utf-8') as f:
    data = f.read()

original = data

pattern_share_center = "        downloadPrepared: false\r\n      },"
replacement_share_center = "        downloadPrepared: false,\r\n        manualAttachmentHintShown: false\r\n      },"
if pattern_share_center not in data:
    sys.exit('pattern_share_center not found')

data = data.replace(pattern_share_center, replacement_share_center, 1)

pattern_reset = "      this.shareCenter.downloadPrepared = false;"
replacement_reset = "      this.shareCenter.downloadPrepared = false;\r\n      this.shareCenter.manualAttachmentHintShown = false;"
if pattern_reset not in data:
    sys.exit('pattern_reset not found')

data = data.replace(pattern_reset, replacement_reset)

start_marker = "    async tryShareWithNativeAPI(dataUrl, filename) {"
end_marker = "    /**\r\n     * 공유 메시지 생성"
start = data.find(start_marker)
if start == -1:
    sys.exit('start_marker not found')
end = data.find(end_marker, start)
if end == -1:
    sys.exit('end_marker not found after start_marker')
new_block = "    async tryShareWithNativeAPI(dataUrl, filename) {\r\n      if (typeof navigator === 'undefined' || typeof navigator.share !== 'function') {\r\n        return false;\r\n      }\r\n\r\n      const shareText = this.buildShareMessage(filename);\r\n\r\n      if (typeof File === 'function') {\r\n        try {\r\n          const blob = this.dataUrlToBlob(dataUrl);\r\n          const file = new File([blob], filename, { type: 'image/png' });\r\n\r\n          if (typeof navigator.canShare !== 'function' || navigator.canShare({ files: [file] })) {\r\n            await navigator.share({\r\n              files: [file],\r\n              title: 'Workflow 공유 스냅샷',\r\n              text: shareText\r\n            });\r\n            this.logAction(`공유 완료(Web Share API + 파일): ${filename}`);\r\n            return true;\r\n          }\r\n\r\n          console.warn('네이티브 공유가 파일 첨부를 지원하지 않아 공유 센터로 전환합니다.');\r\n          this.logAction('네이티브 공유가 파일 첨부를 지원하지 않아 공유 센터로 전환합니다.');\r\n        } catch (error) {\r\n          console.warn('파일 첨부 공유 실패, 사용자 정의 공유 센터로 전환합니다.', error);\r\n          this.logAction(`파일 첨부 공유 실패: ${error.message}`);\r\n        }\r\n      } else {\r\n        this.logAction('현재 환경이 File 생성자를 지원하지 않아 공유 센터를 사용합니다.');\r\n      }\r\n\r\n      return false;\r\n    },\r\n\r\n"
data = data[:start] + new_block + data[end:]

start_marker_email = "    async shareViaEmail() {"
end_marker_email = "    /**\r\n     * 문자 메시지 공유"
start_email = data.find(start_marker_email)
if start_email == -1:
    sys.exit('start_marker_email not found')
end_email = data.find(end_marker_email, start_email)
if end_email == -1:
    sys.exit('end_marker_email not found after start_marker_email')
new_email_block = "    async shareViaEmail() {\r\n      if (!this.shareCenter.message || !this.shareCenter.dataUrl || !this.shareCenter.filename) {\r\n        alert('공유 메시지가 아직 준비되지 않았습니다.');\r\n        return;\r\n      }\r\n\r\n      if (typeof navigator !== 'undefined' && typeof navigator.share === 'function') {\r\n        try {\r\n          const blob = this.dataUrlToBlob(this.shareCenter.dataUrl);\r\n          const file = new File([blob], this.shareCenter.filename, { type: 'image/png' });\r\n\r\n          if (typeof navigator.canShare !== 'function' || navigator.canShare({ files: [file] })) {\r\n            await navigator.share({\r\n              files: [file],\r\n              title: 'Workflow 이미지 공유',\r\n              text: this.shareCenter.message\r\n            });\r\n            this.logAction('메일 공유 완료 (Web Share API, 이미지 첨부됨)');\r\n            return;\r\n          }\r\n\r\n          console.warn('Web Share API가 파일 첨부를 지원하지 않습니다. mailto로 전환합니다.');\r\n          this.logAction('메일 공유: 브라우저가 파일 첨부 공유를 지원하지 않아 mailto로 전환합니다.');\r\n        } catch (error) {\r\n          console.warn('Web Share API 파일 공유 실패, mailto로 폴백:', error);\r\n          this.logAction(`메일 공유 파일 첨부 실패: ${error.message}`);\r\n        }\r\n      } else {\r\n        this.logAction('메일 공유: Web Share API를 사용할 수 없어 mailto로 전환합니다.');\r\n      }\r\n\r\n      if (!this.shareCenter.downloadPrepared) {\r\n        this.downloadShareImage();\r\n      }\r\n\r\n      if (!this.shareCenter.manualAttachmentHintShown) {\r\n        alert('PNG 파일이 자동으로 다운로드되었습니다. 메일 작성 시 해당 파일을 직접 첨부해 주세요.');\r\n        this.shareCenter.manualAttachmentHintShown = true;\r\n      }\r\n\r\n      const subject = encodeURIComponent('Workflow 이미지 공유');\r\n      const bodyLines = [\r\n        this.shareCenter.message,\r\n        '',\r\n        'PNG 파일이 다운로드 폴더에 저장되어 있습니다. 메일에 직접 첨부해 주세요.'\r\n      ];\r\n      const body = encodeURIComponent(bodyLines.join('\\n'));

      window.location.href = `mailto:?subject=${subject}&body=${body}`;\r\n      this.logAction('메일 공유 링크 실행 (mailto, 수동 첨부 안내)');\r\n    },\r\n\r\n"
data = data[:start_email] + new_email_block + data[end_email:]

if data == original:
    sys.exit('No changes made')

with open(path, 'w', encoding='utf-8', newline='\r\n') as f:
    f.write(data)
