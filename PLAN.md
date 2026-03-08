# 구현 계획: Sandbox Options를 통한 특성 설정

## 목표
하드코딩된 특성 목록(excluded/preselected)을 **Sandbox Options의 enum 드롭다운**으로 교체하여,
게임 생성 시 설정 창에서 각 특성별로 **일반/제외/필수선택**을 고를 수 있게 합니다.

---

## 핵심 설계

### Sandbox Options: 특성별 enum 드롭다운
각 특성에 대해 3가지 선택지를 가진 enum 옵션을 생성합니다:
- **1 = 일반 (Normal)** — 랜덤 대상에 포함 (기본값)
- **2 = 제외 (Exclude)** — 랜덤에서 절대 선택 안 됨
- **3 = 필수선택 (Preselect)** — 랜덤 돌리면 무조건 포함

두 개의 페이지로 분리:
- `PM_RandomizeTraits_GoodTraits` — 좋은 특성 설정
- `PM_RandomizeTraits_BadTraits` — 나쁜 특성 설정

### 포함할 특성 목록

**현재 하드코딩된 특성 (총 13개):**

| 한국어 | 영어 | Trait Type ID | 종류 | 출처 |
|--------|------|---------------|------|------|
| 슈퍼 면역 | Super-Immune | `superimmune` | 좋은 | MoreTraits |
| 회피 기동 | Evasive | `evasive` | 좋은 | MoreTraits |
| 운이 좋은 | Lucky | `Lucky` | 좋은 | Vanilla |
| 정리정돈 | Organized | `Organized` | 좋은 | Vanilla |
| 운동능력 | Athletic | `Athletic` | 좋은 | Vanilla |
| 힘센 | Strong | `Strong` | 좋은 | Vanilla |
| 팔 절단 | Amputee | `amputee` | 나쁜 | MoreTraits |
| 청각장애 | Deaf | `Deaf` | 나쁜 | Vanilla |
| 대충대충 | Incomprehensive | `incomprehensive` | 나쁜 | MoreTraits |
| 비체계적인 | Disorganized | `Disorganized` | 나쁜 | Vanilla |
| 불운 | Unlucky | `Unlucky` | 나쁜 | Vanilla |
| 다친 | Injured | `injured` | 나쁜 | MoreTraits |
| 다리 부러짐 | Broke Leg | `broke` | 나쁜 | MoreTraits |
| 화상 환자 | Burn Ward Patient | `burned` | 나쁜 | MoreTraits |

> **참고**: MoreTraits는 소문자 ID(`superimmune`), Vanilla는 PascalCase(`Lucky`)를 사용합니다.

---

## 변경 파일 및 작업 내용

### 1. `media/sandbox-options.txt` — 전면 재작성

기존 `PreselectInjered` 하나를 제거하고, 특성별 enum 옵션으로 교체합니다.

```
VERSION = 1,

-- ===== 좋은 특성 =====
option PM_RandomizeTraits.Trait_superimmune
{
    type = enum,
    numValues = 3,
    default = 2,           -- 기존: 제외됨
    page = PM_RandomizeTraits_GoodTraits,
    translation = PM_RandomizeTraits_Trait_superimmune,
    valueTranslation = PM_RandomizeTraits_TraitSetting,
}

option PM_RandomizeTraits.Trait_evasive
{
    type = enum,
    numValues = 3,
    default = 2,           -- 기존: 제외됨
    page = PM_RandomizeTraits_GoodTraits,
    translation = PM_RandomizeTraits_Trait_evasive,
    valueTranslation = PM_RandomizeTraits_TraitSetting,
}

option PM_RandomizeTraits.Trait_Lucky { ... default = 3 }      -- 기존: 필수선택
option PM_RandomizeTraits.Trait_Organized { ... default = 3 }   -- 기존: 필수선택
option PM_RandomizeTraits.Trait_Athletic { ... default = 3 }    -- 기존: 필수선택
option PM_RandomizeTraits.Trait_Strong { ... default = 3 }      -- 기존: 필수선택

-- ===== 나쁜 특성 =====
option PM_RandomizeTraits.Trait_amputee { ... default = 2 }     -- 기존: 제외됨
option PM_RandomizeTraits.Trait_Deaf { ... default = 2 }        -- 기존: 제외됨
option PM_RandomizeTraits.Trait_incomprehensive { ... default = 2 } -- 기존: 제외됨
option PM_RandomizeTraits.Trait_Disorganized { ... default = 2 }    -- 기존: 제외됨
option PM_RandomizeTraits.Trait_Unlucky { ... default = 2 }     -- 기존: 제외됨
option PM_RandomizeTraits.Trait_injured { ... default = 3 }     -- 기존: 필수선택
option PM_RandomizeTraits.Trait_broke { ... default = 3 }       -- 기존: 필수선택
option PM_RandomizeTraits.Trait_burned { ... default = 3 }      -- 기존: 필수선택
```

enum 값 의미:
- `1` = 일반 (Normal)
- `2` = 제외 (Exclude)
- `3` = 필수선택 (Preselect)

### 2. `PM_CharacterCreationProfession.lua` — 핵심 로직 리팩토링

**변경 핵심: 배열 인덱스 기반 → SandboxVars + trait type ID 기반**

```lua
-- 변경 전 (하드코딩):
local PM_excludedTraits = {
    self.listboxTrait.items[#self.listboxTrait.items-4].text,
    self.listboxTrait.items[#self.listboxTrait.items-8].text,
};

-- 변경 후 (SandboxVars에서 동적으로 구성):
local PM_excludedTraits = {}
local PM_preselectedTraits = {}
local PM_excludedBadTraits = {}
local PM_preselectedBadTraits = {}

-- 좋은 특성 설정 읽기
local goodTraitIDs = {"superimmune", "evasive", "Lucky", "Organized", "Athletic", "Strong"}
for _, traitID in ipairs(goodTraitIDs) do
    local setting = SandboxVars.PM_RandomizeTraits["Trait_" .. traitID]
    if setting == 2 then      -- 제외
        table.insert(PM_excludedTraits, traitID)
    elseif setting == 3 then  -- 필수선택
        table.insert(PM_preselectedTraits, traitID)
    end
end

-- 나쁜 특성도 동일한 패턴
```

**특성 매칭 방식도 변경:**
```lua
-- 변경 전: text(표시 이름)로 비교 — 언어에 따라 깨짐
PM_has_value(PM_excludedTraits, self.listboxTrait.items[idx].text)

-- 변경 후: item:getType() (trait type ID)로 비교 — 언어 무관, 안정적
PM_has_value(PM_excludedTraits, self.listboxTrait.items[idx].item:getType())
```

### 3. 번역 파일 추가/수정

**`media/lua/shared/Translate/EN/Sandbox_EN.txt`** (새 파일 - 영어 기본 번역):
```
Sandbox_PM_RandomizeTraits_GoodTraits = "Randomize Traits - Good Traits",
Sandbox_PM_RandomizeTraits_BadTraits = "Randomize Traits - Bad Traits",

Sandbox_PM_RandomizeTraits_TraitSetting_1 = "Normal",
Sandbox_PM_RandomizeTraits_TraitSetting_2 = "Exclude",
Sandbox_PM_RandomizeTraits_TraitSetting_3 = "Preselect",

Sandbox_PM_RandomizeTraits_Trait_superimmune = "Super-Immune",
-- ... (각 특성별 번역)
```

**`media/lua/shared/Translate/KO/Sandbox_KO.txt`** (기존 파일 수정):
```
Sandbox_PM_RandomizeTraits_GoodTraits = "특성 랜덤 - 좋은 특성",
Sandbox_PM_RandomizeTraits_BadTraits = "특성 랜덤 - 나쁜 특성",

Sandbox_PM_RandomizeTraits_TraitSetting_1 = "일반",
Sandbox_PM_RandomizeTraits_TraitSetting_2 = "제외",
Sandbox_PM_RandomizeTraits_TraitSetting_3 = "필수선택",

Sandbox_PM_RandomizeTraits_Trait_superimmune = "슈퍼 면역",
-- ... (각 특성별 한국어 번역)
```

### 4. `PM_RandomizeTraitsModOptionsConfig.lua` — 버그 수정

```lua
-- 변경 전 (11줄 버그: HardPreselect가 Preselect를 덮어씀):
PM_RandomizeTraits.settings.Preselect = optionValues.settings.options.HardPreselect;

-- 변경 후:
PM_RandomizeTraits.settings.HardPreselect = optionValues.settings.options.HardPreselect;
```

### 5. 트레잇 ID 진단 유틸리티 (선택사항)

나중에 새로운 특성을 추가하고 싶을 때를 위해, 모든 trait ID를 콘솔에 출력하는 진단 함수를 추가합니다:

```lua
function PM_PrintAllTraitIDs()
    local allTraits = TraitFactory.getTraits()
    print("=== All Available Trait IDs ===")
    for i=0, allTraits:size()-1 do
        local trait = allTraits:get(i)
        print(trait:getType() .. " | " .. trait:getLabel() .. " | cost: " .. trait:getCost())
    end
end
```

---

## 새로운 특성을 추가하는 방법 (향후 확장)

1. 진단 함수(`PM_PrintAllTraitIDs`)로 원하는 특성의 trait type ID를 확인
2. `sandbox-options.txt`에 새 옵션 추가 (좋은 특성이면 `GoodTraits` 페이지, 나쁜 특성이면 `BadTraits` 페이지)
3. `PM_CharacterCreationProfession.lua`의 `goodTraitIDs` 또는 `badTraitIDs` 배열에 새 ID 추가
4. 번역 파일에 새 번역 추가

---

## 작업 순서

1. `sandbox-options.txt` — 14개 특성의 enum 옵션 정의
2. `PM_CharacterCreationProfession.lua` — SandboxVars 기반으로 리팩토링 + trait type ID 매칭
3. 번역 파일 — EN/KO 번역 생성
4. `PM_RandomizeTraitsModOptionsConfig.lua` — HardPreselect 버그 수정
5. (선택) 진단 유틸리티 함수 추가
