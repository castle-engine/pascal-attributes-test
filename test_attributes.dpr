// -*- compile: "castle-engine simple-compile test_attributes.dpr && ./test_attributes" -*-
program test_attributes;

{$modeswitch prefixedattributes}

uses SysUtils, Rtti, Classes,
  CastleClassUtils, CastleUIControls, CastleColors, CastleComponentSerialize;

type
  { Register component to be available in CGE editor.
    This allows to add the component from CGE editor menus,
    and to (de)serialize the component instances using CastleComponentSerialize. }
  CastleComponentAttribute = class(TCustomAttribute)
    RegisteredCaption: String;
    constructor Create(const ARegisteredCaption: String);
    constructor Create;
  end;

constructor CastleComponentAttribute.Create(const ARegisteredCaption: String);
begin
  inherited Create;
  RegisteredCaption := ARegisteredCaption;
end;

constructor CastleComponentAttribute.Create;
begin
  Create('');
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
  { Ancestor of TCastleUserInterface that recognizes CastleComponent attribute. }
  TAnnotatedCastleUserInterface = class(TCastleUserInterface)
  end;

type
  [CastleComponent]
  TMyFancyImage1 = class(TAnnotatedCastleUserInterface)
    class constructor ClassCreate;
  end;

  [CastleComponent('My Fancy Image')] // 'My Fancy Image' title optional, by default we guess it
  TMyFancyImage = class(TAnnotatedCastleUserInterface)
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
    class constructor ClassCreate;
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
    { In FPC it is not possible to attach attributes to methods, even published.
      Should be possible in Delphi according to docs.
    [CastleTest]
    class procedure TestSomethingAutomatic;
    }

    { In FPC it is not possible to attach attributes to methods, even published.
      Should be possible in Delphi according to docs.
    [CastleMenu('Reload URL')]
    procedure ReloadUrl;
    }

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

procedure ProcessPerClassAttributes(const ClassType: TComponentClass; const ClassTypeInfo: Pointer);
var
  Context: TRttiContext;
  AType: TRttiType;
  Attribute: TCustomAttribute;
  RegisteredCaption: String;
begin
  Writeln('ProcessPerClassAttributes ', ClassType.ClassName);

  Context := TRttiContext.Create;
  try
    AType := Context.GetType(ClassTypeInfo);
    for Attribute in AType.GetAttributes do
    begin
      Writeln('Found Attribute on ', ClassType.ClassName, ' of type ', Attribute.ClassName);
      if Attribute is CastleComponentAttribute then
      begin
        RegisteredCaption := CastleComponentAttribute(Attribute).RegisteredCaption;
        if RegisteredCaption = '' then
          RegisteredCaption := ClassType.ClassName; // TODO: remove T, add spaces between Words
        Writeln('Registering ', ClassType.ClassName, ' with caption ', RegisteredCaption);
        RegisterSerializableComponent(ClassType, RegisteredCaption);
      end;
    end;
  finally
    Context.Free;
  end;
end;

{ TODO: This is pointless if we have to use ClassCreate on each class that
  may have CastleComponent.

  We don't need to use class constructor for it too.

  Direct RegisterSerializableComponent is now much simpler than this.
}
class constructor TMyFancyImage1.ClassCreate;
begin
  inherited;
  ProcessPerClassAttributes(TComponentClass(ClassType), TypeInfo(TMyFancyImage1));
end;

{ TODO: This is pointless if we have to use ClassCreate on each class that
  may have CastleComponent. }
class constructor TMyFancyImage.ClassCreate;
begin
  inherited;
  ProcessPerClassAttributes(TComponentClass(ClassType), TypeInfo(TMyFancyImage));
end;

// var
//   I1: TMyFancyImage1;
//   I2: TMyFancyImage;
begin
  // I1 := TMyFancyImage1.Create(nil);
  // I2 := TMyFancyImage.Create(nil);
end.
