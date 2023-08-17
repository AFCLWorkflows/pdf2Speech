package function;

import lombok.*;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class SynthesizeInput {
  private String inputFile;
  private String outputBucket;
  private String language;
  private String provider;
}
