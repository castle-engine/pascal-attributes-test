// -*- compile: "castle-engine simple-compile test_attributes.dpr && ./test_attributes" -*-
program test_attributes;

{$modeswitch prefixedattributes}

uses SysUtils,
  CastleClassUtils, CastleUIControls, CastleColors;

type
  { Register component to be available in CGE editor.
    This allows to add the component from CGE editor menus,
    and to (de)serialize the component instances using CastleComponentSerialize. }
  CastleComponentAttribute = class(TCustomAttribute)
    constructor Create(const MenuItem: String);
    constructor Create;
  end;

constructor CastleComponentAttribute.Create(const MenuItem: String);
begin
  inherited Create;
end;

constructor CastleComponentAttribute.Create;
begin
  Create('TODO generate name');
end;

type
  { Execute given class method as part of automatic tests. }
  CastleTestAttribute = class(TCustomAttribute)
    constructor Create;
  end;

constructor CastleTestAttribute.Create;
begin
  inherited;
end;

type
  { Execute given instance method from a context menu on given component from CGE editor. }
  CastleMenuAttribute = class(TCustomAttribute)
    constructor Create(const MenuItemCaption: String);
  end;

constructor CastleMenuAttribute.Create(const MenuItemCaption: String);
begin
  inherited Create;
end;

type
  { Make the given vector property (de)serialized and available in CGE editor
    object inspector.
    This effectively makes the vector "published", even though we cannot publish
    the vector types in FPC.

    TODO: Cal this CastlePublishedVector or just CastlePublished?

    TODO: How to limit what can be influenced by this atrribute?
    Only properties, only of vector types. }
  CastleSerializedVectorAttribute = class(TCustomAttribute)
    constructor Create;
  end;

constructor CastleSerializedVectorAttribute.Create;
begin
  inherited;
end;

type
  { Make the given property available in given property sections in CGE editor. }
  CastlePropertySectionsAttribute = class(TCustomAttribute)
    constructor Create(const Sections: TPropertySections);
  end;

constructor CastlePropertySectionsAttribute.Create(const Sections: TPropertySections);
begin
end;

type
  [CastleComponent]
  TMyFancyImage1 = class(TCastleUserInterface)
  end;

  [CastleComponent('My Fancy Image')] // 'My Fancy Image' title optional, by default we guess it
  TMyFancyImage = class(TCastleUserInterface)
  private
    { In FPC it is not possible to attach attributes to methods.
      Should be possible in Delphi according to docs.
    [CastleTest]
    class procedure TestSomethingAutomatic;
    }

    { In FPC it is not possible to attach attributes to methods.
      Should be possible in Delphi according to docs.
    [CastleMenu('Reload URL')]
    procedure ReloadUrl;
    }

    FColor: TCastleColor;
    FAdvancedColor: TCastleColor;
    FUrl: String;
    FAdvancedSomething: String;
  public
    { In FPC you cannot annotate non-published properties.
      Maybe possible in Delphi.
    [CastleSerializedVector]
    property Color: TCastleColor read FColor write FColor;
    }

    { In FPC you cannot annotate non-published properties.
      Maybe possible in Delphi.
    [CastleSerializedVector]
    [CastlePropertySections([])]
    property AdvancedColor: TCastleColor read FAdvancedColor write FAdvancedColor;
    }
  published
    property Url: String read FUrl write FUrl;

    // Note: FPC and Delphi allow multiple attributes, using both syntaxes:
    {
    [CastleSomething]
    [CastlePropertySections([])]
    property xxx...;

    [CastleSomething, CastlePropertySections([])]
    property xxx...;
    }

    [CastlePropertySections([])]
    property AdvancedSomething: String read FAdvancedSomething write FAdvancedSomething;

    { In FPC you cannot publish vector properties.
      Maybe possible in Delphi.
    [CastleSerializedVector]
    property AdvancedColor2: TCastleColor read FAdvancedColor write FAdvancedColor;
    }
  end;

begin
end.
